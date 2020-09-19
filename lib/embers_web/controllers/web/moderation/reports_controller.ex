defmodule EmbersWeb.Web.Moderation.ReportsController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts
  alias Embers.Reports
  alias Embers.Reports.PostReport

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, [permission: "access_reports_queue"])

  def index(conn, params) do
    posts_reports =
      PostReport.list_reported_posts(
        pagination: [before: params["before"]]
      )

    render(conn, "index.html", posts_reports: posts_reports)
  end

  def create_post_report(conn, %{"post_id" => id} = params) do
    user = conn.assigns.current_user
    reportable = Posts.get_post!(id)

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
    with {:ok, post} <- Posts.get_post(post_id),
         :ok <- Reports.resolve_for(post) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end

  def mark_post_nsfw_and_resolve(conn, %{"post_id" => post_id}) do
    with(
      {:ok, post} <- Posts.get_post(post_id),
      {:ok, _tag} <- Embers.Tags.add_tag(post, "nsfw")
    ) do
      Reports.resolve_for(post)

      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end

  def disable_post_and_resolve(conn, %{"post_id" => post_id}) do
    user = conn.assigns.current_user
    with(
      {:ok, post} <- Posts.get_post(post_id),
      {:ok, post} = Posts.delete_post(post, actor: user.id)
    ) do
      Reports.resolve_for(post)

      EmbersWeb.Endpoint.broadcast!(
        "post:#{post.id}",
        "deleted",
        %{}
      )

      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end
end
