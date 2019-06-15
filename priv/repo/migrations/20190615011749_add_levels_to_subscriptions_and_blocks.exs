defmodule Embers.Repo.Migrations.AddLevelsToSubscriptionsAndBlocks do
  use Ecto.Migration

  def change do
    alter table(:tags_users) do
      add(:level, :integer, null: false, default: 1)
    end

    alter table(:tag_blocks) do
      add(:level, :integer, null: false, default: 1)
    end

    alter table(:user_subscriptions) do
      add(:level, :integer, null: false, default: 1)
    end

    alter table(:user_blocks) do
      add(:level, :integer, null: false, default: 1)
    end
  end
end
