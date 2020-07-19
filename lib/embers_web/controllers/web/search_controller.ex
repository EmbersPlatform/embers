defmodule EmbersWeb.SearchController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Search
  alias Embers.Search.UserSearch

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

  def user_typeahead(conn, %{"username" => username}) do
    results = UserSearch.search(username)

    conn
    |> render("user_results.json", %{results: results})
  end
end
