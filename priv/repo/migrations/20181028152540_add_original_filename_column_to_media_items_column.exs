defmodule Embers.Repo.Migrations.AddOriginalFilenameColumnToMediaItemsColumn do
  use Ecto.Migration

  def change do
    alter table(:media_items) do
      add(:original_filename, :string)
    end
  end
end
