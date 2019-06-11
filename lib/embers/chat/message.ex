defmodule Embers.Chat.Message do
  @moduledoc """
  Mensaje de chat.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "chat_messages" do
    belongs_to(:sender, Embers.Accounts.User)
    belongs_to(:receiver, Embers.Accounts.User)

    field(:text, :string)

    field(:read_at, :utc_datetime)
    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:sender_id, :receiver_id, :text, :read_at])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:receiver_id)
    |> trim_text(attrs)
    |> validate_length(:text, min: 1, max: 1600)
    |> validate_required([:text])
  end

  def read_changeset(message) do
    message
    |> change(read_at: DateTime.utc_now())
  end

  defp trim_text(changeset, %{"text" => text} = _attrs) do
    changeset
    |> change(text: String.trim(text))
  end
end
