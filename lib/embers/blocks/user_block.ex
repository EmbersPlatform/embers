defmodule Embers.Blocks.UserBlock do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "user_blocks" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:source, Embers.Accounts.User)
    field(:level, :integer, null: false, default: 1)

    timestamps()
  end

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, [:user_id, :source_id, :level])
    |> validate_required([:user_id, :source_id])
    |> validate_fields(attrs)
    |> unique_constraint(:unique_user_blocks)
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
end
