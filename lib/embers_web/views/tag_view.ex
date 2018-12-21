defmodule EmbersWeb.TagView do
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("tags.json", %{entries: tags} = metadata) do
    %{
      tags: render_many(tags, __MODULE__, "tag.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("tags_ids.json", %{entries: ids} = metadata) do
    %{
      ids: render_many(ids, __MODULE__, "tag_id"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("tag_id", %{tag: id}) do
    IdHasher.encode(id)
  end

  def render("tag.json", %{tag: %{source: tag}}) do
    %{
      id: IdHasher.encode(tag.id),
      name: tag.name
    }
  end
end
