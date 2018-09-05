defmodule Embers.Repo.Migrations.CreateUserSettingsTable do
  use Ecto.Migration

  def change do
    create table(:user_settings) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      add(:content_nsfw, :string, default: "hide")
      add(:content_lowres_images, :boolean, default: false)

      add(:privacy_show_status, :boolean, default: true)
      add(:privacy_show_reactions, :boolean, default: true)

      timestamps()
    end
  end
end
