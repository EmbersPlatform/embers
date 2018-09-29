defmodule Embers.Feed.Blocks.Blocks do
  @moduledoc """
  Module to interface with blocks

  To block is to avoid any sort of contact with the blockable.
  For example, the user wont receive posts in his feed from blocked users or tags.
  """

  alias Embers.Feed.Blocks.UserBlock
  alias Embers.Repo

  def block_user(attrs \\ %{}) do
    %UserBlock{}
    |> UserBlock.changeset(attrs)
    |> Repo.insert()
  end
end
