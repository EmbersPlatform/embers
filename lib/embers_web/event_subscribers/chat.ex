defmodule EmbersWeb.ChatSubscriber do
  @moduledoc false
  use GenServer

  alias EmbersWeb.Api.ChatView

  def start_link(defaults) when is_list(defaults) do
    GenServer.start_link(__MODULE__, defaults)
  end

  def init(init_args) do
    Embers.Chat.subscribe()

    {:ok, init_args}
  end

  def handle_info({Embers.Chat, [:message, :created], message}, state) do
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

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
