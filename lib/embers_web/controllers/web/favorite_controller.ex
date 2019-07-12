defmodule EmbersWeb.FavoriteController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Favorites
  alias Embers.Helpers.IdHasher

  action_fallback(EmbersWeb.FallbackController)
  plug(:user_check when action in [:update, :delete])

  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    favs =
      Favorites.list_paginated(user.id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "favorites.json", favs)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"post_id" => post_id} = _params
      ) do
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
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"post_id" => id}) do
    id = IdHasher.decode(id)

    Favorites.delete(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end
end
