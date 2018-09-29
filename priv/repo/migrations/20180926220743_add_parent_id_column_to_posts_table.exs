defmodule Embers.Repo.Migrations.AddParentIdColumnToPostsTable do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:parent_id, references(:posts, on_delete: :delete_all), null: true)
      add(:nesting_level, :integer, null: false, default: 0)
    end
  end
end
