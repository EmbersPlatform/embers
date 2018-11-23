defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Feed
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])

  def index(conn, _params) do
    posts = Feed.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    params |> IO.inspect()
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
          create_activity_and_push(post)
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
    render(conn, "show.json", post: post)
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
    # Retrieve post creator followers
    recipients = Feed.Subscriptions.list_followers(post.user_id)

    # Create activity entries for the post
    Feed.push_acitivity(post, [post.user_id | recipients])

    Enum.each(recipients, fn recipient ->
      # Broadcast the good news to the recipients via Channels
      hashed_id = IdHasher.encode(recipient)
      encoded_post = EmbersWeb.PostView.render("post.json", %{post: post})
      payload = %{post: encoded_post}

      EmbersWeb.Endpoint.broadcast!("feed:#{hashed_id}", "new_activity", payload)
    end)
  end
end
