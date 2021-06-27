defmodule EmbersWeb.Plugs.InitialData do
  import Plug.Conn

  alias Embers.Accounts
  alias Embers.Subscriptions
  alias Embers.LoadingMsg
  alias Embers.Notifications

  def init(default), do: default

  def call(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _options
      )
      when not is_nil(current_user) do
    user = Accounts.get_user_by_id(current_user.id)
    put_in(user.settings, Embers.Profile.Settings.get_setting!(user.id))

    tags = Subscriptions.Tags.list_subscribed_tags(user.id)

    tags =
      EmbersWeb.TagView.render(
        "tags.json",
        %{tags: tags}
      )

    notifications = Notifications.list_notifications_paginated(user.id)

    notifications =
      EmbersWeb.NotificationView.render(
        "notifications.json",
        notifications
      )

    unread_conversations = Embers.Chat.list_unread_conversations(user.id)

    conn
    |> assign(:user, user)
    |> assign(:tags, tags)
    |> assign(:notifications, notifications.items)
    |> assign(:loading_msg, LoadingMsg.get_random())
    |> assign(:unread_conversations, unread_conversations)
  end

  def call(conn, _options), do: conn
end
