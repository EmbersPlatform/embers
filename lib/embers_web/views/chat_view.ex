defmodule EmbersWeb.ChatView do
  @moduledoc false

  use EmbersWeb, :view

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      text: message.text,
      read_at: message.read_at,
      inserted_at: message.inserted_at,
      nonce: message.nonce
    }
    |> handle_users(message)
  end

  def render("messages.json", %{messages: messages}) do
    %{
      body:
        Enum.map(messages.entries, fn message ->
          render(
            __MODULE__,
            "message.json",
            %{message: message}
          )
        end),
      next: messages.next,
      last_page: messages.last_page
    }
  end

  def render("conversations.json", %{conversations: conversations}) do
    render_many(conversations, EmbersWeb.Api.UserView, "user.json")
  end

  defp handle_users(view, message) do
    view =
      if Ecto.assoc_loaded?(message.sender) do
        Map.put(
          view,
          :sender,
          render_one(message.sender, EmbersWeb.Api.UserView, "user.json")
        )
      end || view

    view = Map.put(view, :sender_id, message.sender_id)

    view =
      if Ecto.assoc_loaded?(message.receiver) do
        Map.put(
          view,
          :receiver,
          render_one(message.receiver, EmbersWeb.Api.UserView, "user.json")
        )
      end || view

    view = Map.put(view, :receiver_id, message.receiver_id)

    view
  end
end
