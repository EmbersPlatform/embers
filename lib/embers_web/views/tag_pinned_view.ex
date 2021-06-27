defmodule EmbersWeb.TagPinnedView do
  use EmbersWeb, :view

  def render("list_pinned.json", %{tags: tags}) do
    tags
  end
end
