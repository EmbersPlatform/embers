defmodule Embers.Feed.Subscriptions.TagSubscription do
  use Ecto.Schema

  import Ecto.Changeset

  schema "tags_users" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:source, Embers.Tags.Tag)

    timestamps()
  end

  @doc false
  def create_changeset(sub, attrs) do
    sub
    |> cast(attrs, [:user_id, :source_id])
    |> validate_required([:user_id, :source_id])
    |> unique_constraint(:unique_tag_subscription, name: :unique_tag_subscription)
  end
end
