defmodule EmbersWeb.Web.Moderation.DeletedPostController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts

  def index(conn, params) do
    posts = Posts.list_disabled([before: params["before"]])

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(posts)
      |> render("entries.html", posts: posts)
    else
      conn
      |> render("index.html", posts: posts)
    end
  end
end
