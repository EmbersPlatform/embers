defmodule Embers.Repo.Migrations.AddDescriptionToTags do
  use Ecto.Migration

  def change do
    change table(:tags) do
      add(:description, :text)
    end
  end
end
