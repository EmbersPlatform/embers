defmodule Embers.Repo.Migrations.AddUserAssocToMediaItems do
  use Ecto.Migration

  def change do
    alter table(:media_items) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
    end
  end
end
