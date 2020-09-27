defmodule EmbersWeb.Web.Moderation.UserController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Accounts

  def index(conn, params) do
    users = Accounts.list_users_paginated(
      before: params["before"],
      order: :desc
    )

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(users)
      |> render("entries.html", users: users)
    else
      conn
      |> render("index.html", users: users)
    end
  end
end
