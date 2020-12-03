defmodule EmbersWeb.Api.FavoriteController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Favorites

  action_fallback(EmbersWeb.Web.FallbackController)
  plug(:user_check when action in [:update, :delete])

  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    favs =
      Favorites.list_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "favorites.json", favs)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"post_id" => post_id} = _params
      ) do
    case Favorites.create(user.id, post_id) do
      {:ok, _} ->
        conn
        |> json(nil)

      {:error,
       %Ecto.Changeset{
         errors: [
           unique_favorite: _
         ]
       }} ->
        conn
        |> json(nil)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"post_id" => id}) do
    Favorites.delete(user.id, id)

    conn |> json(nil)
  end
end
