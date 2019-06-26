defmodule EmbersWeb.ChatSubscriber do
  @moduledoc false
  use Embers.EventSubscriber, topics: ~w(chat_message_created)

  import Embers.Helpers.IdHasher

  alias EmbersWeb.ChatView

  def handle_event(:chat_message_created, %{data: %{message: message} = data}) do
    %{sender_id: sender, receiver_id: receiver} = message
    temp_id = Map.get(data, :temp_id)

    EmbersWeb.Endpoint.broadcast!(
      "user:#{encode(sender)}",
      "new_chat_message",
      ChatView.render("ws_message.json", message: message, temp_id: temp_id)
    )

    if sender != receiver do
      EmbersWeb.Endpoint.broadcast!(
        "user:#{encode(receiver)}",
        "new_chat_message",
        ChatView.render("ws_message.json", message: message, temp_id: nil)
      )
    end
  end
end
