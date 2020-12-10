defmodule Embers.Repo.Migrations.CreateUserTrgmIndex do
  use Ecto.Migration

  def up do
    if pg_trgm_enabled?() do
      execute(
        "CREATE INDEX IF NOT EXISTS users_canonical_trgm_index ON users USING gin (canonical gin_trgm_ops);",
      )
    end
  end

  def down do
    execute("DROP INDEX IF EXISTS users_canonical_trgm_index;")
  end

  defp pg_trgm_enabled?() do
    Application.get_env(:embers, :db_extensions) |> Keyword.get(:pg_trgm, true)
  end
end
