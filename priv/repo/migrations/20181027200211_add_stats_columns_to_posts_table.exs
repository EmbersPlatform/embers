defmodule Embers.Repo.Migrations.AddParentIdColumnToPostsTable do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:replies_count, :integer, null: false, default: 0)
      add(:shares_count, :integer, null: false, default: 0)
    end
  end
end
