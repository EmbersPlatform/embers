defmodule EmbersWeb.ChatSubscriber do
  @moduledoc false
  use Embers.EventSubscriber, topics: ~w(chat_message_created)

  alias EmbersWeb.Api.ChatView

  def handle_event(:chat_message_created, %{data: %{message: message} = _data}) do
    %{sender_id: sender, receiver_id: receiver} = message

    EmbersWeb.Endpoint.broadcast!(
      "user:#{sender}",
      "new_chat_message",
      ChatView.render("message.json", message: message)
    )

    if sender != receiver do
      EmbersWeb.Endpoint.broadcast!(
        "user:#{receiver}",
        "new_chat_message",
        ChatView.render("message.json", message: message)
      )
    end
  end
end
