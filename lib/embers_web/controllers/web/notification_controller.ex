defmodule EmbersWeb.NotificationController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Helpers.IdHasher
  alias Embers.Notifications

  plug(:user_check)

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    results =
      Notifications.list_notifications_paginated(user.id,
        before: IdHasher.decode(params["before"]),
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        mark_as_read: params["mark_as_read"]
      )

    render(conn, "notifications.json", notifications: results)
  end

  def read(conn, %{"id" => id} = _params) do
    id = IdHasher.decode(id)

    Notifications.set_status(id, 2)

    conn
    |> put_status(:no_content)
    |> json(nil)
  end
end
