defmodule Embers.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, null: false)
      add(:canonical, :string, null: false)
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:confirmed_at, :utc_datetime)
      add(:reset_sent_at, :utc_datetime)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:username]))
  end
end
