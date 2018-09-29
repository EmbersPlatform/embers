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
    post_params = Map.put(params, "user_id", user.id)

    post_params =
      if(Map.has_key?(params, "parent_id")) do
        %{post_params | "parent_id" => IdHasher.decode(params["parent_id"])}
      else
        post_params
      end

    case Feed.create_post(post_params) do
      {:ok, post} ->
        user = Embers.Accounts.get_with_meta(user.canonical)
        post = %{post | user: user}

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

  def update(conn, %{"id" => id, "post" => post_params}) do
    id = IdHasher.decode(id)
    post = Feed.get_post!(id)

    case Feed.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Feed.get_post!(id)
    {:ok, _post} = Feed.delete_post(post)

    render(conn, "show.json", post: post)
  end

  def show_replies(conn, %{"id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)
    results = Feed.get_post_replies(parent_id, params)

    render(conn, "show_replies.json", results)
  end
end
