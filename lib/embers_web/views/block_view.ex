defmodule EmbersWeb.BlockView do
  use EmbersWeb, :view

  alias EmbersWeb.UserView
  alias Embers.Helpers.IdHasher

  def render("blocks.json", %{entries: blocks} = metadata) do
    %{
      blocks: render_many(blocks, __MODULE__, "friend.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("blocks_ids.json", %{entries: ids} = metadata) do
    %{
      ids: render_many(ids, __MODULE__, "friend_id"),
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
