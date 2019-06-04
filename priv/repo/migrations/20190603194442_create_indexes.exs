defmodule Embers.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create(index(:posts_medias, [:post_id, :media_item_id]))
    create(index(:link_post, [:link_id, :post_id]))
    create(index(:tags_posts, [:tag_id, :post_id]))
    create(index(:reactions, [:post_id]))
    create(index(:posts, :user_id))
    create(index(:posts, :parent_id))
    create(index(:posts, :deleted_at))
    create(index(:posts, :nesting_level))
    create(index(:posts, :related_to_id))
    create(index(:user_metas, :user_id))
    create(index(:feed_activity, :user_id))
    create(index(:feed_activity, :post_id))
  end
end
