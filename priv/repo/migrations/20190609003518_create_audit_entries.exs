defmodule Embers.Repo.Migrations.CreateAuditEntries do
  use Ecto.Migration

  def change do
    create table(:audit_entries) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:action, :string)
      add(:source, :string)
      add(:details, {:array, :map}, default: [])

      timestamps()
    end
  end
end
