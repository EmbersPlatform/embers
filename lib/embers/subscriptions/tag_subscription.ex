defmodule Embers.Subscriptions.TagSubscription do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "tags_users" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    belongs_to(:source, Embers.Tags.Tag, type: Embers.Hashid)
    field(:level, :integer, null: false, default: 1)

    timestamps()
  end

  @doc false
  def create_changeset(sub, attrs) do
    sub
    |> cast(attrs, [:user_id, :source_id, :level])
    |> validate_required([:user_id, :source_id])
    |> validate_number(:level, less_than_or_equal_to: 1, greater_than_or_equal_to: 0)
    |> unique_constraint(:unique_tag_subscription, name: :unique_tag_subscription)
  end
end
