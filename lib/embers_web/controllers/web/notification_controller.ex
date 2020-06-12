defmodule EmbersWeb.Web.NotificationController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Notifications
  alias Embers.Helpers.IdHasher

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:index])

  def index(%{assigns: %{current_user: user}} = conn, params) do
    results =
      Notifications.list_notifications_paginated(user.id,
        before: IdHasher.decode(params["before"]),
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        mark_as_read: params["mark_as_read"]
      )

    conn
    |> put_layout(false)
    |> Embers.Paginator.put_page_headers(results)
    |> render("notifications.html", notifications: results.entries)
  end
end
