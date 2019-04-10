defmodule EmbersWeb.Admin.UserController do
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Helpers.IdHasher

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    page =
      Accounts.list_users_paginated(
        before: IdHasher.decode(params["before"]),
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        name: params["name"]
      )

    render(conn, "list.html", users: page.entries, next: page.next, last_page: page.last_page)
  end
end
