defmodule Embers.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @valid_types ~w(follow comment mention)

  @type t :: %__MODULE__{}

  schema "notifications" do
    field(:type, :string, null: false)
    field(:source_id, :integer)
    field(:text, :string)
    field(:read, :boolean)

    belongs_to(:user, Embers.Accounts.User)

    timestamps()
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:type, :user_id, :source_id, :text])
    |> validate_required([:type])
    |> validate_type(attrs)
  end

  defp validate_type(changeset, attrs) do
    case Enum.member?(@valid_types, attrs["type"]) do
      true ->
        changeset

      false ->
        changeset
        |> add_error(
          :invalid_type,
          "The given type is invalid, use one of: #{Enum.join(@valid_types, " ")}"
        )
    end
  end
end
