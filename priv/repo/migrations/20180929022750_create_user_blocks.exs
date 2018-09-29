defmodule Embers.Repo.Migrations.CreateUserBlocks do
  use Ecto.Migration

  def change do
    create table(:user_blocks) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:source_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
