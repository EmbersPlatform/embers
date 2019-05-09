defmodule Embers.Feed.Subscriptions.TagBlock do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "tag_blocks" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:tag, Embers.Tags.Tag)

    timestamps()
  end

  @doc false
  def create_changeset(sub, attrs) do
    sub
    |> cast(attrs, [:user_id, :tag_id])
    |> validate_required([:user_id, :tag_id])
    |> unique_constraint(:unique_tag_block, name: :unique_tag_block)
  end
end
