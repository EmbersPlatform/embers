defmodule Embers.Repo.Migrations.CreateRoleUsers do
  use Ecto.Migration

  def change do
    create table(:role_user) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:role_id, references(:roles, on_delete: :delete_all), null: false)
    end

    create(unique_index(:role_user, [:user_id, :role_id], name: :unique_role_user))
  end
end
