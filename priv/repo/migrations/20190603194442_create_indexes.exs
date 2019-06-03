defmodule Embers.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create(index(:posts_medias, [:post_id, :media_item_id]))
    create(index(:link_post, [:link_id, :post_id]))
    create(index(:tags_posts, [:tag_id, :post_id]))
    create(index(:reactions, [:post_id]))
    create(index(:posts, [:parent_id]))
    create(index(:posts, [:related_to_id]))
  end
end
