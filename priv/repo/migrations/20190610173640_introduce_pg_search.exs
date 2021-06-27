defmodule Embers.Repo.Migrations.IntroducePgSearch do
  use Ecto.Migration

  def up do
    if pg_trgm_enabled?() do
      execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    end
  end

  def down do
    if pg_trgm_enabled?() do
      execute("DROP EXTENSION IF EXISTS pg_trgm")
    end
  end

  defp pg_trgm_enabled?() do
    Application.get_env(:embers, :db_extensions, []) |> Keyword.get(:pg_trgm, true)
  end
end
