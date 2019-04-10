defmodule EmbersWeb.PageController do
  use EmbersWeb, :controller

  alias Embers.Repo
  alias Embers.Accounts.User
  alias Embers.Profile.Meta

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

    tags = Embers.Feed.Subscriptions.Tags.list_subscribed_tags(user.id)

    tags =
      EmbersWeb.TagView.render(
        "tags.json",
        %{tags: tags}
      )

    notifications = Embers.Notifications.list_notifications_paginated(user.id)

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

    render(conn, "index.html", user: user, tags: tags, notifications: notifications.items)
  end

  def auth(conn, _params) do
    render(conn, "auth.json", conn: conn)
  end
end
