defmodule EmbersWeb.Web.Moderation.ReportsController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Helpers.IdHasher
  alias Embers.Posts
  alias Embers.Reports
  alias Embers.Reports.PostReport

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, [permission: "access_reports_queue"])

  def index(conn, params) do
    posts_reports =
      PostReport.list_paginated(
        pagination: [before: params["before"]],
        preload: [
            :media,
            :links,
            :tags,
            :reactions,
            user: [:meta],
            related_to: [:media, :tags, :links, :reactions, user: :meta]
          ]
       )
      |> Embers.Paginator.map(fn report ->
        report = update_in(report.post.id, &IdHasher.encode/1)
        report = update_in(report.post.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
        report
      end)

    render(conn, "index.html", posts_reports: posts_reports)
  end

  def create_post_report(conn, %{"post_id" => id} = params) do
    user = conn.assigns.current_user
    reportable = Posts.get_post!(IdHasher.decode(id))

    attrs = [comments: params["comments"]]

    with {:ok, _report} <- Reports.report(reportable, user, attrs) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def resolve(conn, %{"post_id" => post_id}) do
    post_id = IdHasher.decode(post_id)

    with {:ok, post} <- Posts.get_post(post_id),
         :ok <- Reports.resolve_for(post) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end
end
