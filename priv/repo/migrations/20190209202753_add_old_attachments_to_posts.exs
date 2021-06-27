defmodule Embers.Repo.Migrations.AddOldAttachmentsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:old_attachment, {:map, :string}, null: true)
    end
  end
end
