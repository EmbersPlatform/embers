defmodule EmbersWeb.NotificationController do
  @moduledoc false

  use EmbersWeb, :controller

  use Embers.PubSubBroadcaster

  import EmbersWeb.Authorize

  alias Embers.Notifications

  action_fallback(EmbersWeb.FallbackController)

  plug(:user_check)

  def index(conn, params) do
    user = conn.assigns.current_user

    results =
      Notifications.list_notifications_paginated(user.id,
        before: params["before"],
        after: params["after"],
        limit: params["limit"],
        mark_as_read: params["mark_as_seen"]
      )

    conn
    |> put_layout(false)
    |> Embers.Paginator.put_page_headers(results)
    |> render("notifications.html", notifications: results.entries)
  end

  def read(conn, %{"id" => id} = _params) do
    user = conn.assigns.current_user
    id = id

    Notifications.set_status(id, 2)
    broadcast([:notification, :read], %{id: id, user_id: user.id})

    conn
    |> json(nil)
  end
end
