defmodule Embers.Repo.Migrations.CreateMediaItemsTable do
  use Ecto.Migration

  def change do
    create table(:media_items) do
      add(:url, :string, null: false)
      add(:temporary, :boolean, default: true)

      timestamps()
    end
  end
end
