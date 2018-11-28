defmodule EmbersWeb.UserChannel do
  use Phoenix.Channel

  alias EmbersWeb.Presence
  alias Embers.Helpers.IdHasher

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
    track_user_presence(user)
    {:noreply, socket}
  end

  defp check_user(id, socket) do
    %Phoenix.Socket{assigns: %{user: user}} = socket
    IdHasher.decode(id) == user.id
  end

  # Let's pretend that the current user is allowed to see the presence of users with an id between
  # 10 less than and 100 more than it's own id.
  defp friend_list(user_id) do
    Embers.Feed.Subscriptions.list_mutuals(user_id)
  end

  # Track the current process as a presence for the given user on it's designated presence topic
  defp track_user_presence(user) do
    encoded_id = IdHasher.encode(user.id)

    {:ok, _} =
      Presence.track(self(), presence_topic(user.id), user.username, %{
        id: encoded_id,
        username: user.username,
        avatar: user.meta.avatar,
        online_at: inspect(System.system_time(:seconds))
      })
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

      Presence.list(topic)
    end)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(acc, map) end)
  end

  defp presence_topic(user_id) do
    "user_presence:#{user_id}"
  end
end
