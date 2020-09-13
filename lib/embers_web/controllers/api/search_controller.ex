defmodule EmbersWeb.Api.SearchController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Search
  alias Embers.Search.UserSearch

  def search(conn, params) do
    query = Map.get(params, "query", "")

    results =
      Search.search(query,
        after: params["after"],
        before: params["before"],
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
