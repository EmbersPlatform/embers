defmodule Embers.Repo.Migrations.AddStyleThemeToProfileSettings do
  use Ecto.Migration

  def change do
    alter table(:user_settings) do
      add(:style_theme, :string, default: "dark")
    end
  end
end
