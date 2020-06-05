defmodule EmbersWeb.Web.FavoriteController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Favorites
  alias Embers.Helpers.IdHasher

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:create, :delete])

  def create(conn, %{"post_id" => post_id} = _params) do
    user = conn.assigns.current_user
    post_id = IdHasher.decode(post_id)

    case Favorites.create(user.id, post_id) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)
        |> json(nil)

      {:error,
       %Ecto.Changeset{
         errors: [
           unique_favorite: _
         ]
       }} ->
        conn
        |> put_status(:no_content)
        |> json(nil)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"post_id" => id}) do
    id = IdHasher.decode(id)

    Favorites.delete(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end
end
