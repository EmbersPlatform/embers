defmodule Embers.Blocks.TagBlock do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "tag_blocks" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    belongs_to(:tag, Embers.Tags.Tag, type: Embers.Hashid)
    field(:level, :integer, null: false, default: 1)

    timestamps()
  end

  @doc false
  def create_changeset(sub, attrs) do
    sub
    |> cast(attrs, [:user_id, :tag_id, :level])
    |> validate_required([:user_id, :tag_id])
    |> unique_constraint(:unique_tag_block, name: :unique_tag_block)
  end
end
