defmodule Embers.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add(:sender_id, references(:users, on_delete: :delete_all))
      add(:receiver_id, references(:users, on_delete: :delete_all))
      add(:text, :text)
      add(:read_at, :utc_datetime, null: true)

      timestamps()
    end
  end
end
