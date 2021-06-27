defmodule Embers.Repo.Migrations.AddUniqueIndexToUserBlocks do
  use Ecto.Migration

  def up do
    create(unique_index(:user_blocks, [:user_id, :source_id], name: :unique_user_block))
  end

  def down do
    drop(index(:user_blocks, [:unique_user_block]))
  end
end
