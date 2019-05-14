defmodule EmbersWeb.SearchController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Search

  def search(conn, params) do
    query = Map.get(params, "query", "")

    results =
      Search.search(query,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    conn
    |> render("results.json", results)
  end
end
