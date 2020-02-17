defmodule EmbersWeb.Admin.DashboardController do
  @moduledoc false

  use EmbersWeb, :controller

  import Ecto.Query
  alias Embers.Repo

  plug(:put_layout, "dashboard.html")

  def index(conn, _params) do
    users_count = get_users_count()
    reports_count = get_reports_count()

    assigns = %{users_count: users_count, reports_count: reports_count}
    render(conn, "dashboard.html", assigns)
  end

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> json(:not_found)
  end

  defp get_users_count() do
    from(user in "users",
      select: count(user.id)
    )
    |> Repo.one()
  end

  defp get_reports_count() do
    from(r in "post_reports",
      distinct: r.post_id,
      where: not r.resolved,
      select: r.post_id
    )
    |> Repo.all()
    |> Enum.count()
  end
end
