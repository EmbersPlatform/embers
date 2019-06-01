defmodule Embers.Repo.Migrations.CreateSettingsTable do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add(:name, :string, null: false)
      add(:string_value, :text)
      add(:int_value, :integer)

      timestamps()
    end
  end
end
