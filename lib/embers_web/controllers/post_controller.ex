defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  import Ecto.Query
  alias Embers.{Feed, Feed.Post, Tags}
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])

  def index(conn, _params) do
    posts = Feed.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    post_params = Map.put(params, "user_id", user.id)

    post_params =
      if(Map.has_key?(params, "parent_id")) do
        %{post_params | "parent_id" => IdHasher.decode(params["parent_id"])}
      else
        post_params
      end

    case Feed.create_post(post_params) do
      {:ok, post} ->
        user = Embers.Accounts.get_populated(user.canonical)
        post = %{post | user: user}

        # Asynchronously create activity entries and push to realtime
        Task.Supervisor.start_child(Embers.Feed.FeedSupervisor, fn ->
          handle_tags(post, params)

          if(post.nesting_level == 0) do
            create_activity_and_push(post)
          end
        end)

        Task.Supervisor.start_child(Embers.Feed.FeedSupervisor, fn ->
          handle_mentions(post)
        end)

        conn
        |> render("show.json", post: post)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post_id = IdHasher.decode(id)
    post = Feed.get_post!(post_id)

    render(conn, "show.json", %{post: post})
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Feed.get_post!(id)

    case is_post_owner?(user, post) do
      true ->
        {:ok, _post} = Feed.delete_post(post)

      false ->
        conn |> put_status(:forbidden) |> json(nil)
    end

    render(conn, "show.json", post: post)
  end

  def show_replies(conn, %{"id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)
    results = Feed.get_post_replies(parent_id, params)

    render(conn, "show_replies.json", results)
  end

  defp is_post_owner?(user, post) do
    user.id == post.user_id
  end

  defp create_activity_and_push(post) do
    followers = Feed.Subscriptions.list_followers_ids(post.user_id)
    blocked = Feed.Subscriptions.Blocks.list_users_ids_that_blocked(post.user_id)
    tags = Embers.Tags.list_post_tags_ids(post.id)

    tags_subscriptors =
      from(
        sub in Feed.Subscriptions.TagSubscription,
        where: sub.source_id in ^tags,
        select: sub.user_id
      )
      |> Embers.Repo.all()

    tags_blockers =
      from(
        block in Feed.Subscriptions.TagBlock,
        where: block.tag_id in ^tags,
        select: block.user_id
      )
      |> Embers.Repo.all()

    exceptions = Enum.concat(blocked, tags_blockers)

    recipients =
      Enum.concat(followers, tags_subscriptors)
      |> Enum.reject(fn el -> Enum.member?(exceptions, el) end)
      |> Enum.concat([post.user_id])
      |> Enum.uniq()

    # Create activity entries for the post
    Feed.push_acitivity(post, recipients)

    recipients
    |> Enum.reject(fn recipient -> recipient == post.user_id end)
    |> Enum.each(fn recipient ->
      # Broadcast the good news to the recipients via Channels
      hashed_id = IdHasher.encode(recipient)
      encoded_post = EmbersWeb.PostView.render("post.json", %{post: post})
      payload = %{post: encoded_post}

      EmbersWeb.Endpoint.broadcast!("feed:#{hashed_id}", "new_activity", payload)
    end)
  end

  defp handle_mentions(%Post{body: body} = post) do
    regex = ~r/(?:^|[^a-zA-Z0-9_＠!@#$%&*])(?:(?:@|＠)(?!\/))([a-zA-Z0-9_]{1,15})(?:\b(?!@|＠)|$)/
    results = Regex.scan(regex, body) |> Enum.map(fn [_, txt] -> txt end)

    recipients =
      from(
        user in Embers.Accounts.User,
        where: user.canonical in ^results,
        select: user.id
      )
      |> Embers.Repo.all()

    recipients
    |> Enum.reject(fn recipient -> recipient.id == post.user_id end)
    |> Enum.each(fn recipient ->
      hashed_id = IdHasher.encode(recipient)

      EmbersWeb.Endpoint.broadcast!("user:#{hashed_id}", "mention", %{
        from: post.user.canonical,
        source: IdHasher.encode(post.id)
      })
    end)
  end

  defp handle_tags(post, params) do
    hashtag_regex = ~r/(?<!\w)#\w+/

    hashtags =
      Regex.scan(hashtag_regex, post.body)
      |> Enum.map(fn [txt] -> String.replace(txt, "#", "") end)

    hashtags =
      if Map.has_key?(params, "tags") and is_list(params["tags"]) do
        Enum.concat(hashtags, params["tags"])
      else
        hashtags
      end

    tags_ids = Tags.bulk_create_tags(hashtags)

    tag_post_list =
      Enum.map(tags_ids, fn tag_id ->
        %{
          post_id: post.id,
          tag_id: tag_id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Embers.Repo.insert_all(Embers.Tags.TagPost, tag_post_list)
  end
end
