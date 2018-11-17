defmodule Embers.Repo.Migrations.AddFilenameColumnToMediaItemsColumn do
  use Ecto.Migration

  def change do
    alter table(:media_items) do
      add(:filename, :string)
    end
  end
end
