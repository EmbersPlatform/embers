defmodule Embers.Repo.Migrations.CreateTagBlock do
  use Ecto.Migration

  def change do
    create table(:tag_blocks) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:tag_blocks, [:user_id, :tag_id], name: :unique_tag_block))
  end
end
