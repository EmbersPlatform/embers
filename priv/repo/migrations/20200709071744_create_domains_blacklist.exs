defmodule Embers.Repo.Migrations.CreateDomainsBlacklist do
  use Ecto.Migration

  def change do
    create table(:domains_blacklist) do
      add(:domain, :string, null: false)

      timestamps()
    end

    create unique_index(:domains_blacklist, [:domain])
  end
end
