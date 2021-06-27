defmodule EmbersWeb.Moderation.DashboardController do
  @moduledoc false

  use EmbersWeb, :controller

  def index(conn, _params) do
    last_users = Embers.Stats.Accounts.get_last_registered_users()

    conn
    |> assign(:last_users, last_users)
    |> render("index.html", page_title: gettext("Dashboard"))
  end
end
