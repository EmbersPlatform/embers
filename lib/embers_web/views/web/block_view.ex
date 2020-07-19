defmodule EmbersWeb.BlockView do
  @moduledoc false

  use EmbersWeb, :view

  alias EmbersWeb.UserView
  alias Embers.Helpers.IdHasher

  def render("blocks.json", %{entries: blocks} = metadata) do
    %{
      items: render_many(blocks, __MODULE__, "block.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("blocks_ids.json", %{entries: ids} = metadata) do
    %{
      ids: render_many(ids, __MODULE__, "block_ids"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("block_id", %{block: id}) do
    IdHasher.encode(id)
  end

  def render("block.json", %{block: block}) do
    render_one(block.user, UserView, "user.json")
  end
end
