defmodule Embers.Repo.Migrations.AddTimestampsToActivities do
  use Ecto.Migration

  def change do
    alter table(:feed_activity) do
      timestamps(null: true)
    end
  end
end
