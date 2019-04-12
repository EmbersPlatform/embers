defmodule Embers.Repo.Migrations.CreateLoadingMsgTable do
  use Ecto.Migration

  def change do
    create table(:loading_msg) do
      add(:name, :string, null: false)
      add(:title, :string)
      add(:subtitle, :string)
      add(:url, :string)
      add(:background, :boolean, default: false)
      add(:color, :string)
      add(:styles, :string)
      add(:active, :boolean, null: false, default: true)
    end

    unique_index(:loading_msg, :name)
  end
end
