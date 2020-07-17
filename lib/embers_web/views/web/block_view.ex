defmodule EmbersWeb.BlockView do
  @moduledoc false

  use EmbersWeb, :view

  alias EmbersWeb.UserView
  alias Embers.Helpers.IdHasher

  def render("blocks.json", %{blocks: blocks} = _assigns) do
    %{
      items: render_many(blocks.entries, __MODULE__, "block.json"),
      next: blocks.next,
      last_page: blocks.last_page
    }
  end

  def render("blocks_ids.json", %{ids: ids} = _assigns) do
    %{
      ids: render_many(ids.entries, __MODULE__, "block_ids"),
      next: ids.next,
      last_page: ids.last_page
    }
  end

  def render("block_id", %{block: id}) do
    IdHasher.encode(id)
  end

  def render("block.json", %{block: block}) do
    render_one(block.user, UserView, "user.json")
  end
end
