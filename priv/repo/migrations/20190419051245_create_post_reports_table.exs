defmodule Embers.Repo.Migrations.CreatePostReportsTable do
  use Ecto.Migration

  def change do
    create table(:post_reports) do
      add(:reporter_id, references(:users, on_delete: :delete_all), null: false)
      add(:assoc_id, references(:posts, on_delete: :delete_all), null: false)

      add(:comments, :string)
      add(:resolved, :boolean, default: false)

      timestamps(type: :utc_datetime)
    end
  end
end
