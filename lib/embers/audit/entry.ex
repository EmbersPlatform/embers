defmodule Embers.AuditEntry do
  use Ecto.Schema

  import Ecto.Changeset

  schema "audit_entries" do
    belongs_to(:user, Embers.Accounts.User)
    field(:action, :string, null: false)
    field(:source, :string, null: false)
    embeds_many(:details, Embers.AuditDetail)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:user_id, :action, :source])
    |> cast_embed(:details)
    |> validate_required([:action, :source])
  end
end
