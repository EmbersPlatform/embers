defmodule Embers.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:body, :string, size: 1600)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:parent_id, references(:posts, on_delete: :delete_all), null: true)
      add(:nesting_level, :integer, null: false, default: 0)
      add(:replies_count, :integer, null: false, default: 0)
      add(:shares_count, :integer, null: false, default: 0)

      timestamps()
    end

    create(index(:posts, [:user_id]))
  end
end
