defmodule EmbersWeb.Web.FavoriteController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Favorites

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check)

  def list(conn, params) do
    user = conn.assigns.current_user
    favs =
      Favorites.list_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    favs = update_in(favs.entries,
      fn favs ->
        Enum.map(favs,
          fn fav -> fav.post end
        )
      end
    )
    |> Embers.Feed.Utils.load_avatars()

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(favs)
      |> render("entries.html", favorites: favs)
    else
      conn
      |> render("index.html", favorites: favs)
    end
  end

  def create(conn, %{"post_id" => post_id} = _params) do
    user = conn.assigns.current_user

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
    Favorites.delete(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end
end
