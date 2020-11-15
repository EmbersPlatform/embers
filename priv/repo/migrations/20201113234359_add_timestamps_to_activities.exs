defmodule Embers.Repo.Migrations.AddTimestampsToActivities do
  use Ecto.Migration

  def up do
    alter table(:feed_activity) do
      timestamps(null: true)
    end

    execute("""
    UPDATE feed_activity f
    SET inserted_at = (
        SELECT p.inserted_at
        FROM posts p
        WHERE p.id = f.post_id
        LIMIT 1
      )
    ;
    """)

    execute("""
    UPDATE feed_activity
    SET updated_at = inserted_at
    ;
    """)
  end

  def down do
    alter table(:feed_activity) do
      remove(:inserted_at)
      remove(:updated_at)
    end
  end
end
