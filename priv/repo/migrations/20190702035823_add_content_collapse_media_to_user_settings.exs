defmodule Embers.Repo.Migrations.AddContentCollapseMediaToUserSettings do
  use Ecto.Migration

  def change do
    alter table(:user_settings) do
      add(:content_collapse_media, :boolean, default: true)
    end
  end
end
