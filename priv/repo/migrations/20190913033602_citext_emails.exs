defmodule Embers.Repo.Migrations.CitextEmails do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify(:email, :citext, null: false)
    end
  end

  def down do
    alter table(:users) do
      modify(:email, :string, null: false)
    end
  end
end
