defmodule EmbersWeb.UserChannel do
  @moduledoc false
  use Phoenix.Channel

  alias Embers.Subscriptions
  alias EmbersWeb.Presence

  def join("user:" <> id, _payload, socket) do
    case check_user(id, socket) do
      true ->
        send(self(), :after_join)
        {:ok, socket}

      false ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def join("user_presence:" <> _rest, _payload, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket = %{assigns: %{user: user}}) do
    presence_state = get_and_subscribe_presence_multi(socket, friend_list(user.id))
    push(socket, "presence_state", presence_state)
    maybe_track_user_presence(user)
    {:noreply, socket}
  end

  def handle_in("chat_typing", %{"party" => party_id} = _payload, socket) do
    dest_id = socket.assigns.user.id

    EmbersWeb.Endpoint.broadcast!("user:#{party_id}", "chat_typing", %{
      "party" => dest_id
    })

    {:noreply, socket}
  end

  defp check_user(id, socket) do
    %Phoenix.Socket{assigns: %{user: user}} = socket
    id == user.id
  end

  # Let's pretend that the current user is allowed to see the presence of users with an id between
  # 10 less than and 100 more than it's own id.
  defp friend_list(user_id) do
    Subscriptions.list_mutuals_ids(user_id)
  end

  # Track the current process as a presence for the given user on it's designated presence topic
  defp maybe_track_user_presence(user) do
    setting = Embers.Profile.Settings.get_setting!(user.id)

    if not is_nil(setting) and setting.privacy_show_status do
      {:ok, _} =
        Presence.track(self(), presence_topic(user.id), user.username, %{
          id: user.id,
          username: user.username,
          avatar: user.meta.avatar,
          online_at: inspect(System.system_time(:second))
        })
    end
  end

  # Find the presence topics of all given users. Get their presence state and subscribe the current
  # process (channel) to their presence updates.
  defp get_and_subscribe_presence_multi(socket, user_ids) do
    user_ids
    |> Enum.map(&presence_topic/1)
    |> Enum.uniq()
    |> Enum.map(fn topic ->
      :ok =
        Phoenix.PubSub.subscribe(
          socket.pubsub_server,
          topic,
          fastlane: {socket.transport_pid, socket.serializer, []}
        )

      presences = Presence.list(topic)
      presences
    end)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(acc, map) end)
  end

  defp presence_topic(user_id) do
    "user_presence:#{user_id}"
  end
end
