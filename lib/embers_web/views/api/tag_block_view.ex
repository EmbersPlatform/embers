defmodule EmbersWeb.Api.TagBlockView do
  @moduledoc false

  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("tags.json", %{tags: tags}) do
    render_many(tags, __MODULE__, "tag.json")
  end

  def render("tags_paginated.json", %{entries: tags} = metadata) do
    %{
      items: render_many(tags, __MODULE__, "tag.json"),
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
