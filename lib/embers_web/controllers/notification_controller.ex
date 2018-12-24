defmodule EmbersWeb.NotificationController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Notifications

  plug(:user_check)

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    results = Notifications.list_notifications_paginated(user.id, params)
    render(conn, "notifications.json", results)
  end
end
