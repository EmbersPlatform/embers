defmodule Embers.Feed.Subscriptions.UserSubscription do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Embers.Repo

  schema "user_subscriptions" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:source, Embers.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:user_id, :source_id])
    |> validate_required([:user_id, :source_id])
    |> validate_fields(attrs)
    |> validate_unique_entry(attrs)
  end

  defp validate_fields(changeset, attrs) do
    if attrs.user_id == attrs.source_id do
      Ecto.Changeset.add_error(
        changeset,
        :invalid_params,
        "user_id and source_id cant't be the same"
      )
    else
      changeset
    end
  end

  defp validate_unique_entry(changeset, attrs) do
    entries = Repo.get_by(UserSubscription, %{user_id: attrs.user_id, source_id: attrs.source_id})

    if is_nil(entries) do
      changeset
    else
      changeset
      |> Ecto.Changeset.add_error(:already_exists, "subscription already exists")
    end
  end
end
