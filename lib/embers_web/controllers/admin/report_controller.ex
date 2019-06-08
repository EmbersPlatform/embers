defmodule EmbersWeb.Admin.ReportController do
  use EmbersWeb, :controller

  import Ecto.Query
  import Embers.Helpers.IdHasher
  import EmbersWeb.Helpers

  alias Embers.Feed
  alias Embers.Reports
  alias Embers.Reports.{PostReport, UserReport}
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "delete_post"] when action in [:delete_post])
  plug(:put_layout, "dashboard.html")

  def overview(conn, params) do
    posts_reports = PostReport.list_paginated(params)

    posts_reports = %{
      posts_reports
      | entries:
          Enum.map(posts_reports.entries, fn x ->
            %{x | post: %{x.post | id: Embers.Helpers.IdHasher.encode(x.post.id)}}
          end)
    }

    render(conn, "overview.html", posts_reports: posts_reports)
  end

  def post_report(conn, %{"id" => post_id} = params) do
    with {:ok, post} <- Feed.get_post(decode(post_id)) do
      reports =
        from(
          r in PostReport,
          where: r.post_id == ^post.id and r.resolved == false,
          left_join: user in assoc(r, :reporter),
          preload: [reporter: user]
        )
        |> Embers.Repo.paginate(params)

      post = post |> Embers.Repo.preload([:media, :links, :tags, :user])

      common_comments = Reports.most_common_comments_for(post)

      render(conn, "post_report.html",
        post: %{post | id: encode(post.id)},
        reports: reports,
        common_comments: common_comments
      )
    else
      {:error, reason} -> error(conn, reason, report_path(conn, :overview))
    end
  end

  def delete_post(conn, %{"id" => id}) do
    id = decode(id)

    with {:ok, post} <- Feed.get_post(id),
         {:ok, _post} <- Feed.delete_post(post),
         :ok <- Reports.resolve_for(post) do
      success(conn, "Post eliminado y reportes resueltos", report_path(conn, :overview))
    end
  end

  def resolve_post_reports(conn, %{"id" => id}) do
    id = decode(id)

    with {:ok, post} <- Feed.get_post(id),
         :ok <- Reports.resolve_for(post) do
      success(conn, "Reportes resueltos", report_path(conn, :overview))
    end
  end
end
