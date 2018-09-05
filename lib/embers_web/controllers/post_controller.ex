defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Feed
  alias Embers.Feed.Post

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])

  def index(conn, _params) do
    posts = Feed.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def new(conn, _params) do
    changeset = Feed.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"post" => post_params}) do
    post_params = Map.put(post_params, "user_id", user_id)

    case Feed.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Feed.get_post!(id)
    IO.inspect(post)
    render(conn, "show.json", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Feed.get_post!(id)
    changeset = Feed.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Feed.get_post!(id)

    case Feed.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.json", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Feed.get_post!(id)
    {:ok, _post} = Feed.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end
end
