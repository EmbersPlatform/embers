defmodule EmbersWeb.UserSocket do
  use Phoenix.Socket

  alias EmbersWeb.Auth.Token

  ## Channels
  # channel "room:*", EmbersWeb.RoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    case Token.verify(token, max_age: 1_209_600) do
      {:ok, %{"user_id" => user_id}} ->
        socket = assign(socket, :user, Embers.Accounts.get_populated(user_id))
        {:ok, socket}

      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     EmbersWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "user_socket:#{socket.assigns.user.id}"

  ## Channels
  channel("feed:*", EmbersWeb.FeedChannel)

  channel("user:*", EmbersWeb.UserChannel)

  channel("post:*", EmbersWeb.PostChannel)

  channel("mod", EmbersWeb.ModChannel)

  # "user_presence:*" is not meant to be joined, added here to clarify that the topic prefix is used be the UserChannel
  channel("user_presence:*", EmbersWeb.UserChannel)
end
