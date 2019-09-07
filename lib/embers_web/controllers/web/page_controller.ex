defmodule EmbersWeb.PageController do
  use EmbersWeb, :controller

  alias Embers.Accounts.User
  alias Embers.Subscriptions
  alias Embers.LoadingMsg
  alias Embers.Notifications
  alias Embers.Profile.Meta
  alias Embers.Repo

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params)
      when not is_nil(current_user) do
    user =
      User
      |> Repo.get(current_user.id)
      |> Repo.preload([:meta, :settings])

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

    user = %{
      user
      | meta:
          user.meta
          |> Meta.load_avatar_map()
          |> Meta.load_cover()
    }

    unread_conversations =
      Embers.Chat.list_unread_conversations(user.id)
      |> Enum.map(fn x ->
        %{x | party: Embers.Helpers.IdHasher.encode(x.party)}
      end)

    render(conn, "index.html",
      user: user,
      tags: tags,
      notifications: notifications.items,
      loading_msg: LoadingMsg.get_random(),
      unread_conversations: unread_conversations
    )
  end

  def index(conn, params) do
    if is_nil(params["path"]) do
      conn = put_layout(conn, false)
      render(conn, "landing.html")
    else
      render(conn, "index.html")
    end
  end

  def auth(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) when not is_nil(user) do
    tags = Subscriptions.Tags.list_subscribed_tags(user.id)

    render(conn, "auth.json", conn: conn, tags: tags, user: user)
  end

  def auth(conn, _params) do
    render(conn, "auth.json", conn: conn)
  end

  def rules(conn, _params) do
    rules = Embers.Settings.get!("rules")
    send_resp(conn, 200, rules.string_value)
  end

  def faq(conn, _params) do
    faq = Embers.Settings.get!("faq")
    send_resp(conn, 200, faq.string_value)
  end

  def acknowledgments(conn, _params) do
    acknowledgments = Embers.Settings.get!("acknowledgments")
    send_resp(conn, 200, acknowledgments.string_value)
  end
end
