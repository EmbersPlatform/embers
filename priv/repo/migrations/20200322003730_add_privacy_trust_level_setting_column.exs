defmodule Embers.Repo.Migrations.AddPrivacyTrustLevelSettingColumn do
  use Ecto.Migration

  def change do
    alter table(:user_settings) do
      add(:privacy_trust_level, :string, default: "everyone")
    end
  end
end
