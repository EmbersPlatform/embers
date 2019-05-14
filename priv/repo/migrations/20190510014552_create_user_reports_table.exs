defmodule Embers.Repo.Migrations.CreateUserReportsTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_reports) do
      add(:reporter_id, references(:users, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      add(:comments, :string)
      add(:resolved, :boolean, default: false)

      timestamps(type: :utc_datetime)
    end
  end
end
