defmodule Embers.Feed.Subscriptions.UserSubscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_subscriptions" do
    belongs_to :user, Embers.Accounts.User
    belongs_to :source, Embers.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:user_id, :source_id])
    |> validate_required([:user_id, :source_id])
  end
end
