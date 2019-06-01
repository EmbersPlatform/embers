defmodule Embers.Repo.Migrations.CreateLinksTable do
  use Ecto.Migration

  def change do
    create table(:links) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:url, :string, null: false)
      add(:embed, :map, null: false)
      add(:temporary, :boolean, default: true)

      timestamps()
    end
  end
end
