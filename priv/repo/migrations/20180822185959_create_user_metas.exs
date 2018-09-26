defmodule Embers.Repo.Migrations.CreateUserMetas do
  use Ecto.Migration

  def change do
    create table(:user_metas) do
      add(:bio, :string)
      add(:avatar_version, :string)
      add(:cover_version, :string)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
