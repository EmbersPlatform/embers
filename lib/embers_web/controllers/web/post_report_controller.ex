defmodule EmbersWeb.PostReportController do
  @moduledoc false

  use EmbersWeb, :controller

  import Embers.Helpers.IdHasher

  alias Embers.Posts
  alias Embers.Reports
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "create_report"] when action in [:create])
  plug(
    :rate_limit_reports,
    [max_requests: 10, interval_seconds: 60] when action in [:create]
  )

  def rate_limit_reports(conn, options \\ []) do
    options = Keyword.merge(options, bucket_name: "report_creation:#{conn.assigns.current_user.id}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def create(%{assigns: %{current_user: user}} = conn, %{"post_id" => id} = params) do
    reportable = Posts.get_post!(decode(id))

    attrs = [comments: params["comments"]]

    with {:ok, _report} <- Reports.report(reportable, user, attrs) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end
end
