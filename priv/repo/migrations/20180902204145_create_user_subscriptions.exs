defmodule Embers.Repo.Migrations.CreateUserSubscriptions do
  use Ecto.Migration

  def change do
    create table(:user_subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :source_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
