defmodule EmbersWeb.Web.Moderation.DisabledPostController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts

  def index(conn, params) do
    posts = Posts.list_disabled([before: params["before"]])

    disabled_count = Posts.count_disabled()

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(posts)
      |> render("entries.html", posts: posts)
    else
      conn
      |> assign(:page_title, gettext("Disabled posts"))
      |> assign(:posts, posts)
      |> assign(:disabled_count, disabled_count)
      |> render("index.html")
    end
  end

  def restore(conn, %{"post_id" => post_id}) do
    user = conn.assigns.current_user

    with \
      {:ok, post} <- Posts.get_post(post_id),
      {:ok, _} <- Posts.restore_post(post, actor: user)
    do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end

  @todo
  def prune(conn, _params) do
    :not_implemented
  end
end
