defmodule Embers.Repo.Migrations.AddMetadataToUserTokens do
  use Ecto.Migration

  def change do
    alter table(:users_tokens) do
      add :metadata, :map
    end
  end
end
