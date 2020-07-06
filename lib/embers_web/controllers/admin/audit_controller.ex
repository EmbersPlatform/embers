defmodule EmbersWeb.Admin.AuditController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Audit

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    page = Map.get(params, "page")

    action = Map.get(params, "action")
    audits = Audit.list(page: page, action: action)

    render(conn, "list.html", audits: audits)
  end
end
