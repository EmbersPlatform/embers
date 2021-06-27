defmodule Embers.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:post_id, references(:posts, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:favorites, [:user_id, :post_id], name: :unique_favorite))
  end
end
