defmodule Embers.Repo.Migrations.CreateFeedActivity do
  use Ecto.Migration

  def change do
  	create table(:feed_activity) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
    end
  end
end
