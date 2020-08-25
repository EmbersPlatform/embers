defmodule EmbersWeb.Web.SearchController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Helpers.IdHasher
  alias Embers.Search
  alias Embers.Search.UserSearch

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:user_typeahead])

  def search(conn, params) do
    query = Map.get(params, "query", "")

    page =
      Search.search(query,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )
      |> Embers.Paginator.map(fn post ->
        update_in(post.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
      end)

    conn = assign(conn, :page, page)

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(page)
      |> render("results.html")
    else
      conn
      |> assign(:query, query)
      |> render("index.html")
    end
  end

  def user_typeahead(conn, %{"username" => username}) do
    results = UserSearch.search(username)

    conn
    |> render("user_results.json", results: results)
  end
end
