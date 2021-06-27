defmodule Embers.Repo.Migrations.CreateBansTable do
  use Ecto.Migration

  def up do
    create table(:bans) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:reason, :string)
      add(:level, :integer)

      add(:expires_at, :utc_datetime)

      add(:deleted_at, :utc_datetime)

      timestamps()
    end

    alter table(:users) do
      add(:banned_at, :utc_datetime)
    end
  end

  def down do
    drop(table(:bans))

    alter table(:users) do
      remove(:banned_at)
    end
  end
end
