defmodule Embers.Repo.Migrations.UseCitextInUsersCanonicalColumn do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify(:canonical, :citext, null: false)
    end
  end

  def down do
    alter table(:users) do
      modify(:canonical, :string, null: false)
    end
  end
end
