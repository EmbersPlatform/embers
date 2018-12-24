defmodule Embers.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add(:type, :string, null: false)
      add(:from_id, references(:users, on_delete: :delete_all), null: true)
      add(:recipient_id, references(:users, on_delete: :delete_all), null: false)
      add(:source_id, :integer, null: true)
      add(:text, :string, null: true)
      add(:read, :boolean, default: false)

      timestamps()
    end
  end
end
