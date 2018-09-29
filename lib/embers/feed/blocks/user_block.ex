defmodule Embers.Feed.Blocks.UserBlock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_blocks" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:source, Embers.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, [:user_id, :source_id])
    |> validate_required([:user_id, :source_id])
  end
end
