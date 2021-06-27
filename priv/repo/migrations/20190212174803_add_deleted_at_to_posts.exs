defmodule Embers.Repo.Migrations.AddDeletedAtToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:deleted_at, :naive_datetime, null: true)
    end
  end
end
