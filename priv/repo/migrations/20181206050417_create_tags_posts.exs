defmodule Embers.Repo.Migrations.CreateTagsPosts do
  use Ecto.Migration

  def change do
    create table(:tags_posts) do
      add(:post_id, references(:posts, on_delete: :delete_all), null: false)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:tags_posts, [:post_id, :tag_id], name: :unique_relation))
  end
end
