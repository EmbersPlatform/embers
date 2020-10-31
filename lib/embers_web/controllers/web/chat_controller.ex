defmodule EmbersWeb.Web.ChatController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Accounts.User
  alias Embers.Chat

  plug(:user_check)

  action_fallback(EmbersWeb.Web.FallbackController)

  def index(conn, _params) do
    conversations =
      Chat.list_conversations_with(conn.assigns.current_user.id)
      |> Enum.map(fn user -> update_in(user.meta, &Embers.Profile.Meta.load_avatar_map/1) end)

    render(conn, "index.html", conversations: conversations)
  end

  def show(conn, %{"username" => username} = _params) do
    with %User{} = user <- Embers.Accounts.get_populated(%{"canonical" => username}) do
      render(conn, "show.html", user: user)
    end
  end

  def list_conversations(conn, _params) do
    conversations = Chat.list_conversations_with(conn.assigns.current_user.id)

    render(conn, "conversations.json", conversations: conversations)
  end

  def show_messages(conn, %{"id" => user_id} = params) do
    with %User{} = user <- Embers.Accounts.get_populated(user_id) do
      messages =
        Chat.list_messages_for(conn.assigns.current_user.id, user.id, before: params["before"])

      render(conn, "messages.json", messages: messages)
    end
  end

  def create(conn, params) do
    sender = conn.assigns.current_user.id
    params = Map.put(params, "sender_id", sender)
    nonce = Map.get(params, "nonce") |> String.slice(0..9)

    params =
      if !is_nil(params["receiver_id"]) do
        Map.put(params, "receiver_id", params["receiver_id"])
      end || params

    with {:ok, message} <- Chat.create(params, nonce: nonce) do
      render(conn, "message.json", message: %{message | nonce: nonce})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def read(conn, %{"id" => party} = _params) do
    reader = conn.assigns.current_user.id

    Chat.read_conversation(reader, party)

    EmbersWeb.Endpoint.broadcast!(
      "user:#{reader}",
      "conversation_read",
      %{id: party}
    )

    conn
    |> put_status(:no_content)
    |> json(nil)
  end
end
