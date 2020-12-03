defmodule EmbersWeb.Api.NotificationController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Notifications

  plug(:user_check)

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    results =
      Notifications.list_notifications_paginated(user.id,
        before: params["before"],
        after: params["after"],
        limit: params["limit"],
        mark_as_read: params["mark_as_read"]
      )

    render(conn, "notifications.json", results)
  end

  def read(conn, %{"id" => id} = _params) do
    Notifications.set_status(id, 2)

    conn
    |> json(nil)
  end
end
