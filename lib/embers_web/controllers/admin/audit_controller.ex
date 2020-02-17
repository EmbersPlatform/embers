defmodule EmbersWeb.Admin.AuditController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Audit

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    audits = Audit.list(params)

    render(conn, "list.html", audits: audits)
  end
end
