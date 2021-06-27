defmodule Embers.AuditEntry do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "audit_entries" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    field(:action, :string, null: false)
    field(:source, :string, null: false)
    embeds_many(:details, Embers.AuditDetail)

    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:user_id, :action, :source])
    |> cast_embed(:details)
    |> validate_required([:action, :source])
  end
end
