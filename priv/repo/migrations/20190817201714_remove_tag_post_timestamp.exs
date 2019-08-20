defmodule Embers.Repo.Migrations.RemoveTagPostTimestamp do
  use Ecto.Migration

  def up do
    alter table(:tags_posts) do
      modify :inserted_at, :naive_datetime, default: fragment("now()")
      modify :updated_at, :naive_datetime, default: fragment("now()")
    end
  end

  def down do
    alter table(:tags_posts) do
      modify :inserted_at, :naive_datetime, default: nil
      modify :updated_at, :naive_datetime, default: nil
    end
  end
end
