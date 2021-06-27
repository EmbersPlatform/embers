defmodule Embers.Repo.Migrations.CreateReactionsTable do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add(:name, :string, null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:post_id, references(:posts, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:reactions, [:name, :user_id, :post_id], name: :unique_reaction))
  end
end
