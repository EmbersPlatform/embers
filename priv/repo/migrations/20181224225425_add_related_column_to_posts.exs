defmodule Embers.Repo.Migrations.AddRelatedColumnToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:related_to_id, references(:posts, on_delete: :delete_all), null: true)
    end
  end
end
