defmodule EmbersWeb.ChatController do
  @moduledoc false

  use EmbersWeb, :controller

  import Embers.Helpers.IdHasher

  alias Embers.Chat

  def list_conversations(conn, _params) do
    conversations = Chat.list_conversations_with(conn.assigns.current_user.id)

    render(conn, "conversations.json", conversations: conversations)
  end

  def list_messages(conn, %{"id" => party_id} = params) do
    party_id = decode(party_id)

    messages =
      Chat.list_messages_for(conn.assigns.current_user.id, party_id,
        before: decode(params["before"])
      )

    render(conn, "messages.json", messages)
  end

  def create(conn, params) do
    sender = conn.assigns.current_user.id
    params = Map.put(params, "sender_id", sender)
    temp_id = Map.get(params, "temp_id")

    params =
      if !is_nil(params["receiver_id"]) do
        Map.put(params, "receiver_id", decode(params["receiver_id"]))
      end || params

    with {:ok, message} <- Chat.create(params, temp_id: temp_id) do
      render(conn, "message.json", message: message)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def read(conn, %{"id" => id} = _params) do
    reader = conn.assigns.current_user.id
    party = decode(id)

    Chat.read_conversation(reader, party)

    EmbersWeb.Endpoint.broadcast!(
      "user:#{encode(reader)}",
      "conversation_read",
      %{id: id}
    )

    conn
    |> put_status(:no_content)
    |> json(nil)
  end

  def list_unread_conversations(conn, _params) do
    conversations = Chat.list_unread_conversations(conn.assigns.current_user.id)
    conversations = Enum.map(conversations, &encode/1)

    conn
    |> json(conversations)
  end
end
