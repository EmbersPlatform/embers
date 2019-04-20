defmodule Embers.Moderation.Ban do
  use Ecto.Schema

  import Ecto.Changeset

  schema "bans" do
    field(:reason, :string)
    field(:level, :integer, default: 0)
    field(:expires_at, :utc_datetime)
    field(:deleted_at, :utc_datetime)

    belongs_to(:user, Embers.Accounts.User)

    timestamps()
  end

  def changeset(ban, attrs) do
    ban
    |> cast(attrs, [:user_id, :reason, :level, :expires_at])
  end
end
