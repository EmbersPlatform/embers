defmodule EmbersWeb.PageController do
  use EmbersWeb, :controller

  alias Embers.Accounts.User
  alias Embers.Feed
  alias Embers.Feed.Subscriptions
  alias Embers.LoadingMsg
  alias Embers.Notifications
  alias Embers.Profile.Meta
  alias Embers.Repo

  def index(%Plug.Conn{assigns: %{current_user: nil}} = conn, params) do
    if is_nil(params["path"]) do
      conn = put_layout(conn, false)
      render(conn, "landing.html")
    else
      render(conn, "index.html")
    end
  end

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
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

    render(conn, "index.html",
      user: user,
      tags: tags,
      notifications: notifications.items,
      loading_msg: LoadingMsg.get_random()
    )
  end

  def auth(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) when not is_nil(user) do
    tags = Feed.Subscriptions.Tags.list_subscribed_tags(user.id)

    render(conn, "auth.json", conn: conn, tags: tags, user: user)
  end

  def auth(conn, _params) do
    render(conn, "auth.json", conn: conn)
  end
end
