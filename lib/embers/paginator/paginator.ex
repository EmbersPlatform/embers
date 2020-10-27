defmodule Embers.Paginator do
  @moduledoc """
  Paginates a query result using cursor based pagination.
  See [this article](https://coderwall.com/p/lkcaag/pagination-you-re-probably-doing-it-wrong)
  for an explanation of the method used here.
  """

  import Ecto.Query, warn: false

  alias Embers.Paginator.Options
  alias Embers.Paginator.Page
  alias Embers.Repo

  @doc """
  Fetches all the results matching the query between the cursors

  It relies on the `id` column for the cursor

  ## Options

  * `after` - Fetch the records after this id
  * `before` - Fetch the records before this id
  * `limit` - Limits the number of records returned per page. Note that this number
    will be capped by `:max_limit`. Defaults to 20
  * `max_limit` - Sets a maximum cap for `:limit`. This option can be useful when `:limit`
    is set dynamically (e.g from a URL param set by a user) but you still want to
    enforce a maximum. Defaults to `100`.

  ## Usage

      iex> paginate(query, opts)
      %Page{entries: [], last_page: false, next: "next cursor"}

  """
  @spec paginate(Ecto.Query.t(), list()) :: Embers.Paginator.Page.t()
  def paginate(queryable, opts \\ []) do
    opts = Options.build(opts)

    limit_plus_one = opts.limit + 1

    query =
      queryable
      |> limit(^limit_plus_one)

    query =
      unless is_nil(opts.before) do
        case opts.inclusive_cursor do
          true ->
            from(q in query,
              where: q.id <= ^opts.before
            )
          false ->
            from(q in query,
              where: q.id < ^opts.before
            )
        end

      end || query

    query =
      unless is_nil(opts.after) do
        case opts.inclusive_cursor do
          true ->
            from(q in query,
              where: q.id >= ^opts.after
            )
          false ->
            from(q in query,
              where: q.id > ^opts.after
            )
          end
      end || query

    all_entries = Repo.all(query)
    entries_count = Enum.count(all_entries)
    last_entry = List.last(all_entries)
    last_page = entries_count <= opts.limit

    entries =
      if last_page do
        all_entries
      else
        Enum.drop(all_entries, -1)
      end

    next =
      if last_page or is_nil(last_entry) do
        nil
      else
        last_entry.id
      end

    %Page{entries: entries, next: next, last_page: last_page}
  end

  @doc """
  Adds the `embers-page-metadata` header to a given `Plug.Conn`.
  It contains a json encoded map with the page's `next` and `last_page`.
  """
  @spec put_page_headers(Plug.Conn.t(), Embers.Paginator.Page.t()) :: Plug.Conn.t()
  def put_page_headers(conn, page) do
    {:ok, page_metadata} =
      Map.from_struct(page)
      |> Map.drop([:entries])
      |> Jason.encode()

    conn
    |> Plug.Conn.put_resp_header("embers-page-metadata", page_metadata)
  end

  @doc """
  Applies the function to each element in the page entries
  """
  def map(page, fun) do
    update_in(page.entries, fn entries -> Enum.map(entries, fun) end)
  end
end
