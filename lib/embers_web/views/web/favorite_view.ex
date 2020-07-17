defmodule EmbersWeb.FavoriteView do
  @moduledoc false

  use EmbersWeb, :view

  alias EmbersWeb.PostView

  def render("favorites.json", %{favorites: favorites} = _favorites) do
    %{
      items: render_many(favorites.entries, __MODULE__, "favorite.json"),
      next: favorites.next,
      last_page: favorites.last_page
    }
  end

  def render("favorite.json", %{favorite: favorite}) do
    render_one(favorite.post, PostView, "post.json")
  end
end
