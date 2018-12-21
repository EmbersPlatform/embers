defmodule Embers.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add(:type, :string, null: false)
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:source_id, :integer)
      add(:text, :string)
      add(:read, :boolean)

      timestamps()
    end
  end
end
