defmodule EmbersWeb.Admin.ReportController do
  use EmbersWeb, :controller

  import Ecto.Query

  alias Embers.Reports.{PostReport, UserReport}

  plug(:put_layout, "dashboard.html")

  def overview(conn, _params) do
    post_reports_count = from(r in PostReport, select: count(r.id)) |> Embers.Repo.one()

    user_reports_count = from(r in UserReport, select: count(r.id)) |> Embers.Repo.one()

    render(conn, "overview.html", counts: %{post: post_reports_count, user: user_reports_count})
  end
end
