defmodule EmbersWeb.ChatView do
  use EmbersWeb, :view

  import Embers.Helpers.IdHasher

  def render("message.json", %{message: message}) do
    %{
      id: encode(message.id),
      text: message.text,
      read_at: message.read_at,
      inserted_at: message.inserted_at
    }
    |> handle_users(message)
  end

  def render("conversations.json", %{conversations: conversations}) do
    render_many(conversations, EmbersWeb.UserView, "user.json")
  end

  def render("messages.json", %{entries: messages} = metadata) do
    %{
      items:
        Enum.map(messages, fn message ->
          render(
            __MODULE__,
            "message.json",
            %{message: message}
          )
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  defp handle_users(view, message) do
    view =
      if Ecto.assoc_loaded?(message.sender) do
        Map.put(view, :sender, render_one(message.sender, EmbersWeb.UserView, "user.json"))
      end || view

    view = Map.put(view, :sender_id, encode(message.sender_id))

    view =
      if Ecto.assoc_loaded?(message.receiver) do
        Map.put(view, :receiver, render_one(message.receiver, EmbersWeb.UserView, "user.json"))
      end || view

    view = Map.put(view, :receiver_id, encode(message.receiver_id))

    view
  end
end
