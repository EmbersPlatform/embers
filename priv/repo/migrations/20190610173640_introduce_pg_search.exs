defmodule Embers.Repo.Migrations.IntroducePgSearch do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION pg_trgm")
  end

  def down do
    execute("DROP EXTENSION pg_trgm")
  end
end
