defmodule Embers.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add(:name, :string, null: false)
      add(:permissions, {:array, :string})
    end

    create(unique_index(:roles, [:name]))
  end
end
