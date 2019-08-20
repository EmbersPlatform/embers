defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Posts
  alias Embers.Helpers.IdHasher
  alias EmbersWeb.Plugs.CheckPermissions

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])
  plug(CheckPermissions, [permission: "create_post"] when action in [:create])

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    post_params = Map.put(params, "user_id", user.id)

    media_count =
      if is_nil(params["medias"]) || Enum.empty?(params["medias"]) do
        0
      else
        length(params["medias"])
      end

    links_count =
      if is_nil(params["links"]) || Enum.empty?(params["links"]) do
        0
      else
        length(params["links"])
      end

    post_params = Map.put(post_params, "media_count", media_count)
    post_params = Map.put(post_params, "links_count", links_count)

    post_params =
      if Map.has_key?(params, "parent_id") do
        %{post_params | "parent_id" => IdHasher.decode(params["parent_id"])}
      end || post_params

    post_params =
      if Map.has_key?(params, "related_to_id") do
        %{post_params | "related_to_id" => IdHasher.decode(params["related_to_id"])}
      end || post_params

    case Posts.create_post(post_params) do
      {:ok, post} ->
        user = Embers.Accounts.get_populated(user.canonical)
        post = %{post | user: user}

        conn
        |> render("show.json", post: post)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    post_id = IdHasher.decode(id)

    post =
      post_id
      |> Posts.get_post!()
      |> populate_user(conn)

    conn =
      if is_nil(post) do
        put_status(conn, :not_found)
      end || conn

    render(conn, "show.json", %{post: post})
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Posts.get_post!(id)

    case can_delete?(user, post) do
      true ->
        {:ok, _post} = Posts.delete_post(post, actor: user.id)

      false ->
        conn |> put_status(:forbidden) |> json(nil)
    end

    render(conn, "show.json", post: post)
  end

  def show_replies(conn, %{"id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)

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
        limit: params["limit"],
        order: order
      )

    render(conn, "show_replies.json", results)
  end

  defp can_delete?(user, post) do
    Embers.Authorization.is_owner?(user, post) || Embers.Authorization.can?("delete_post", user)
  end

  defp populate_user(nil, _), do: nil

  defp populate_user(post, %Plug.Conn{assigns: %{current_user: current_user}})
       when not is_nil(current_user) do
    %{
      post
      | user: Embers.Accounts.User.load_following_status(post.user, current_user.id)
    }
  end

  defp populate_user(post, _), do: post
end
