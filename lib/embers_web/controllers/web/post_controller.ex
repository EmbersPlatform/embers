defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias EmbersWeb.Plugs.CheckPermissions
  alias Embers.{Feed}
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])
  plug(CheckPermissions, [permission: "create_post"] when action in [:create])

  def index(conn, _params) do
    posts = Feed.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do

    post_params = Map.put(params, "user_id", user.id)

      # Si el body es vacio devuelve error.
      # TODO pensar si es mejor guardar el body trimeado o no

      if (String.trim(post_params["body"]) === "" && length(post_params["medias"]) === 0) do
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: "error"})
      else

      post_params =
        if(Map.has_key?(params, "parent_id")) do
          %{post_params | "parent_id" => IdHasher.decode(params["parent_id"])}
        end || post_params

      post_params =
        if(Map.has_key?(params, "related_to_id")) do
          %{post_params | "related_to_id" => IdHasher.decode(params["related_to_id"])}
        end || post_params

      case Feed.create_post(post_params) do
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
  end

  def show(conn, %{"id" => id}) do
    post_id = IdHasher.decode(id)
    post = Feed.get_post!(post_id)

    conn =
      if is_nil(post) do
        put_status(conn, :not_found)
      end || conn

    render(conn, "show.json", %{post: post})
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Feed.get_post!(id)

    case can_delete?(user, post) do
      true ->
        {:ok, _post} = Feed.delete_post(post)

      false ->
        conn |> put_status(:forbidden) |> json(nil)
    end

    render(conn, "show.json", post: post)
  end

  def show_replies(conn, %{"id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)

    results =
      Feed.get_post_replies(parent_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "show_replies.json", results)
  end

  defp can_delete?(user, post) do
    Embers.Authorization.is_owner?(user, post) || Embers.Authorization.can?("delete_post", user)
  end
end
