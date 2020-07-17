defmodule EmbersWeb.TagBlockView do
  @moduledoc false

  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("tags.json", %{tags: tags}) do
    render_many(tags, __MODULE__, "tag.json")
  end

  def render("tags_paginated.json", %{tags: tags} = _assigns) do
    %{
      items: render_many(tags.entries, __MODULE__, "tag.json"),
      next: tags.next,
      last_page: tags.last_page
    }
  end

  def render("tags_ids.json", %{ids: ids} = _assigns) do
    %{
      ids: render_many(ids.entries, __MODULE__, "tag_id"),
      next: ids.next,
      last_page: ids.last_page
    }
  end

  def render("tag_id", %{tag_block: id}) do
    IdHasher.encode(id)
  end

  def render("tag.json", %{tag_block: tag}) do
    %{
      id: IdHasher.encode(tag.id),
      name: tag.name,
      description: tag.description
    }
  end
end
