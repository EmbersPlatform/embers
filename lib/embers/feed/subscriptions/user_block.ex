defmodule Embers.Feed.Subscriptions.UserBlock do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Embers.Repo

  @type t :: %__MODULE__{}

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
    |> validate_fields(attrs)
    |> validate_unique_entry(attrs)
  end

  defp validate_fields(changeset, attrs) do
    if(attrs.user_id == attrs.source_id) do
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
    entries = Repo.get_by(UserBlock, %{user_id: attrs.user_id, source_id: attrs.source_id})

    if(not is_nil(entries)) do
      changeset
      |> Ecto.Changeset.add_error(:already_exists, "block already exists")
    else
      changeset
    end
  end
end