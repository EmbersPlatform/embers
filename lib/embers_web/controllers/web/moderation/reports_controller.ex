defmodule EmbersWeb.Web.Moderation.ReportsController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts
  alias Embers.Reports
  alias Embers.Reports.PostReport

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, permission: "access_reports_queue")

  def index(conn, params) do
    posts_reports = PostReport.list_reported_posts(pagination: [before: params["before"]])

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(posts_reports)
      |> render("entries.html", posts_reports: posts_reports)
    else
      conn
      |> render("index.html", posts_reports: posts_reports, page_title: gettext("Reports"))
    end
  end

  def resolve(conn, %{"post_id" => post_id}) do
    with {:ok, post} <- Posts.get_post(post_id),
         :ok <- Reports.resolve_for(post) do
      conn
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
      |> json(nil)
    end
  end

  def show_comments(conn, %{"post_id" => post_id} = params) do
    with {:ok, post} <- Posts.get_post(post_id) do
      comments = Reports.get_comments_per_user(post, limit: 10, before: params["before"])

      render(conn, "comments.json", comments: comments)
    end
  end
end
