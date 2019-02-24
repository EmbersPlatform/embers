defmodule Embers.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:body, :string, size: 1600)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:posts, [:user_id]))
  end
end
