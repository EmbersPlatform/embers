defmodule Embers.Repo.Migrations.CreateTagSubscription do
  use Ecto.Migration

  def change do
    create table(:tags_users) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:source_id, references(:tags, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:tags_users, [:user_id, :source_id], name: :unique_tag_subscription))
  end
end
