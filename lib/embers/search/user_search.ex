defmodule Embers.Search.UserSearch do
  import Ecto.Query

  alias Embers.Accounts.User
  alias Embers.Repo

  def search(username, opts \\ []) when is_binary(username) do
    search_term = "%" <> String.replace(username, ~r/\W/u, "") <> "%"
    # limit = Keyword.get(opts, :limit, 0.3)
    except = Keyword.get(opts, :except, nil)

    query =
      from(
        u in User,
        where: ilike(u.canonical, ^search_term),
        preload: [:meta],
        limit: 10
      )
      |> maybe_order_by_similarity(search_term)

    results = Repo.all(query)

    if not is_nil(except) do
      results |> Enum.reject(fn user -> user.canonical == except end)
    else
      results
    end
  end

  defp maybe_order_by_similarity(query, search_term) do
    if pg_trgm_available?() do
      from(u in query,
        order_by: fragment("similarity(?, ?) DESC", u.canonical, ^search_term)
      )
    else
      query
    end
  end

  defp pg_trgm_available?() do
    Application.get_env(:embers, :db_extensions) |> Keyword.get(:pg_trgm, true)
  end
end
