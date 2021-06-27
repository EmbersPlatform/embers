defmodule Embers.Repo.Migrations.CreateLinkPostTable do
  use Ecto.Migration

  def change do
    create table(:link_post) do
      add(:post_id, references(:posts, on_delete: :delete_all), null: false)
      add(:link_id, references(:links, on_delete: :delete_all), null: false)
    end

    create(unique_index(:link_post, [:post_id, :link_id], name: :unique_link_post))
  end
end
