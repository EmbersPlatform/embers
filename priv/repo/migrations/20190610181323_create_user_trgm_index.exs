defmodule Embers.Repo.Migrations.CreateUserTrgmIndex do
  use Ecto.Migration

  def up do
    execute(
      "CREATE INDEX users_canonical_trgm_index ON users USING gin (canonical gin_trgm_ops);"
    )
  end

  def down do
    execute("DROP INDEX users_canonical_trgm_index;")
  end
end
