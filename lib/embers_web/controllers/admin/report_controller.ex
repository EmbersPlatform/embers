defmodule EmbersWeb.Admin.ReportController do
  @moduledoc false

  use EmbersWeb, :controller

  import Ecto.Query
  import EmbersWeb.Helpers

  alias Embers.Posts
  alias Embers.Reports
  alias Embers.Reports.PostReport
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "delete_post"] when action in [:delete_post])
  plug(:put_layout, "dashboard.html")

  def overview(conn, params) do
    posts_reports = PostReport.list_paginated(params)

    render(conn, "overview.html", posts_reports: posts_reports)
  end

  def post_report(conn, %{"id" => post_id} = params) do
    with {:ok, post} <- Posts.get_post(post_id) do
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
        post: post,
        reports: reports,
        common_comments: common_comments
      )
    else
      {:error, reason} -> error(conn, reason, report_path(conn, :overview))
    end
  end

  def delete_post(conn, %{"id" => id}) do
    with {:ok, post} <- Posts.get_post(id),
         {:ok, _post} <- Posts.delete_post(post),
         :ok <- Reports.resolve_for(post) do
      success(conn, "Post eliminado y reportes resueltos", report_path(conn, :overview))
    end
  end

  def resolve_post_reports(conn, %{"id" => id}) do
    with {:ok, post} <- Posts.get_post(id),
         :ok <- Reports.resolve_for(post) do
      success(conn, "Reportes resueltos", report_path(conn, :overview))
    end
  end
end
