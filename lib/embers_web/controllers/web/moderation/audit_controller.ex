defmodule EmbersWeb.Web.Moderation.AuditController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Audit

  def index(conn, params) do
    before = Map.get(params, "before")

    opts = [before: before]

    entries = Audit.list_entries(opts) |> IO.inspect

    conn
    |> assign(:entries, entries)
    |> render("index.html", page_title: gettext("Audit"))
  end
end
