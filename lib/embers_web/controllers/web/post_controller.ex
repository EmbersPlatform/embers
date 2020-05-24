defmodule EmbersWeb.Web.PostController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Helpers.IdHasher
  alias Embers.Posts
  alias Embers.Profile.Meta
  alias Embers.Reactions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:create, :delete, :add_reaction, :remove_reaction])

  plug(
    :rate_limit_post_creation,
    [max_requests: 10, interval_seconds: 60] when action in [:create]
  )

  def rate_limit_post_creation(conn, options \\ []) do
    options = Keyword.merge(options, bucket_name: "post_creation:#{conn.assigns.current_user.id}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def show(conn, %{"hash" => hash} = _params) do
    id = IdHasher.decode(hash)

    with {:ok, post} = Posts.get_post(id) do
      post = put_in(post.user.meta.avatar, Meta.avatar_map(post.user.meta))
      post = put_in(post.user.meta.cover, Meta.cover(post.user.meta))
      post = put_in(post.id, hash)

      replies_page = Posts.get_post_replies(id, limit: 20, replies: 2, replies_order: {:desc, :inserted_at})

      title = post.body || gettext("@%{username}'s post", username: post.user.username)
      conn
      |> render(:show, page_title: title, post: post, replies_page: replies_page)
    end
  end

  def create(%{assigns: %{current_user: user}} = conn, params) do
    params =
      params
      |> Map.put("user_id", user.id)
      |> maybe_put_parent_id()
      |> maybe_put_related_to_id()
      |> maybe_put_medias()
      |> maybe_put_links()
      |> get_and_put_tags()

    with {:ok, post} <- Posts.create_post(params) do
      if not is_nil(post.related_to) and is_nil(post.body) do
        activity = Embers.Feed.FeedActivity.of(post.related_to, post.user)
        conn
        |> put_layout(false)
        |> put_view(EmbersWeb.Web.TimelineView)
        |> render("activity.html", activity: activity, with_replies: true)
      else
        {view, key} =
          cond do
            not is_nil(post.parent_id) and params["as_thread"] -> {:reply_thread, :reply}
            not is_nil(post.parent_id) -> {:reply, :reply}
            true -> {:post, :post}
          end

        conn
        |> put_layout(false)
        |> render(view, [{key, post}])
      end
    end
  end

  defp maybe_put_parent_id(%{"parent_id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)
    Map.put(params, "parent_id", parent_id)
  end

  defp maybe_put_parent_id(params), do: params

  defp maybe_put_related_to_id(%{"related_to_id" => related_to_id} = params) do
    related_to_id = IdHasher.decode(related_to_id)
    Map.put(params, "related_to_id", related_to_id)
  end

  defp maybe_put_related_to_id(params), do: params

  defp maybe_put_medias(%{"medias" => medias} = params) do
    medias =
      for media <- medias,
          %{"id" => id_hash} = media,
          id = IdHasher.decode(id_hash),
          media = Embers.Media.get(id) do
        media
      end

    Map.put(params, "media", medias)
  end

  defp maybe_put_medias(params), do: params

  defp maybe_put_links(%{"links" => links} = params) do
    links =
      for id_hash <- links,
          id = IdHasher.decode(id_hash),
          link = Embers.Links.get_by(%{id: id}) do
        link
      end

    Map.put(params, "links", links)
  end

  defp maybe_put_links(params), do: params

  defp get_and_put_tags(params) do
    body = Map.get(params, "body") || ""
    body_tags = Posts.Post.parse_tags(body)
    provided_tags = Map.get(params, "tags", [])

    tag_names =
      Enum.concat(body_tags, provided_tags)
      |> Enum.reject(fn tag -> tag == "" end)
      |> Enum.uniq()
      |> Enum.take(10)

    tags =
      for name <- tag_names do
        Embers.Tags.create_tag(name)
      end

    Map.put(params, "tags", tags)
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Posts.get_post!(id)

    case can_delete?(user, post) do
      true ->
        {:ok, _post} = Posts.delete_post(post, actor: user.id)
        conn
        |> put_status(:no_content)
        |> json(nil)

      false ->
        conn |> put_status(:forbidden) |> json(nil)
    end
  end

  defp can_delete?(user, post) do
    Embers.Authorization.is_owner?(user, post) || Embers.Authorization.can?("delete_post", user)
  end

  def show_replies(conn, %{"hash" => hash} = params) do
    parent_id = IdHasher.decode(hash)
    limit = Map.get(params, "limit", 2)
    skip_first? = Map.get(params, "skip_first", false)
    replies = if is_binary(params["replies"]) do
      String.to_integer(params["replies"])
    end || false
    as_thread? = Map.get(params, "as_thread", false)

    limit = if skip_first? do
      String.to_integer(limit) + 1
    end || limit

    order =
      case params["order"] do
        "desc" -> :desc
        "asc" -> :asc
        _ -> :asc
      end

    results =
      Posts.get_post_replies(parent_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: limit,
        order: order,
        replies: replies,
        replies_order: {:asc, :inserted_at}
      )

    results = if skip_first? do
      entries = results.entries |> Enum.reverse() |> tl() |> Enum.reverse()
      put_in(results.entries, entries)
    end || results

    {:ok, page_metadata} =
      Map.from_struct(results)
      |> Map.drop([:entries])
      |> Jason.encode()

    conn
    |> put_layout(false)
    |> Plug.Conn.put_resp_header("embers-page-metadata", page_metadata)
    |> render(:show_replies, replies: results, as_thread?: as_thread?)
  end

  def add_reaction(conn, %{"name" => name, "hash" => hash}) do
    user_id = conn.assigns.current_user.id
    post_id = IdHasher.decode(hash)

    case Reactions.create_reaction(%{"name" => name, "user_id" => user_id, "post_id" => post_id}) do
      {:ok, _reaction} ->
        post = Posts.get_post!(post_id)

        conn
        |> put_layout(false)
        |> render("reactions.html", post: post, conn: conn)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  def remove_reaction(conn, %{"name" => name, "hash" => hash}) do
    user_id = conn.assigns.current_user.id
    post_id = IdHasher.decode(hash)

    Reactions.delete_reaction(%{
      "name" => name,
      "post_id" => post_id,
      "user_id" => user_id
    })

    post = Posts.get_post!(post_id)

    conn
    |> put_layout(false)
    |> render("reactions.html", post: post, conn: conn)
  end
end
