defmodule EmbersWeb.FavoriteView do
  use EmbersWeb, :view

  alias EmbersWeb.PostView

  def render("favorites.json", %{entries: favorites} = metadata) do
    %{
      items: render_many(favorites, __MODULE__, "favorite.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("favorite.json", %{favorite: favorite}) do
    render_one(favorite.post, PostView, "post.json")
  end
end
