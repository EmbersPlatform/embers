defmodule Embers.Repo.Migrations.CreatePostsMediasTable do
  use Ecto.Migration

  def change do
    create table(:posts_medias) do
      add(:post_id, references(:posts, on_delete: :delete_all), null: false)
      add(:media_item_id, references(:media_items, on_delete: :delete_all), null: false)
    end
  end
end
