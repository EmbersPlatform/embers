defmodule Embers.Repo do
  use Ecto.Repo, otp_app: :embers

  import Ecto.Query, warn: false

  alias __MODULE__

  @pagination_defaults [
    before: nil,
    after: nil,
    limit: 50,
    max_limit: 500
  ]

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Fetches all the results matching the query between the cursors

  It relies on the `id` column for the cursor

  ## Options

  * `after` - Fetch the records after this id
  * `before` - Fetch the records before this id
  * `limit` - Limits the number of records returned per page. Note that this number
    will be capped by `:max_limit`. Defaults to 50
  * `max_limit` - Sets a maximum cap for `:limit`. This option can be useful when `:limit`
    is set dynamically (e.g from a URL param set by a user) but you still want to
    enfore a maximum. Defaults to `500`.

  ## Usage

      query
      |> Repo.paginate(opts)

  """
  def paginate(queryable, opts \\ []) do
    opts = normalize_pagination_opts(opts)

    limit_plus_one = opts.limit + 1

    query =
      queryable
      |> limit(^limit_plus_one)

    query =
      if(!is_nil(opts.before)) do
        query |> where([q], q.id <= ^opts.before)
      else
        query
      end

    query =
      if(!is_nil(opts.after)) do
        query |> where([q], q.id >= ^opts.after)
      else
        query
      end

    all_entries = Repo.all(query)
    last_entry = List.last(all_entries)
    entries = Enum.drop(all_entries, -1)
    entries_count = Enum.count(all_entries)
    last_page = entries_count <= opts.limit

    next =
      if last_page or is_nil(last_entry) do
        -1
      else
        last_entry.id
      end

    %{entries: entries, next: next, last_page: last_page}
  end

  defp normalize_pagination_opts(opts \\ []) do
    valid_opts = []

    valid_opts =
      if(Map.has_key?(opts, "after") and not is_nil(opts["after"])) do
        case Integer.parse(opts["after"]) do
          {id, _} -> valid_opts ++ [after: id]
          :error -> valid_opts
        end
      else
        valid_opts
      end

    valid_opts =
      if(Map.has_key?(opts, "before") and not is_nil(opts["before"])) do
        case Integer.parse(opts["before"]) do
          {id, _} -> valid_opts ++ [before: id]
          :error -> valid_opts
        end
      else
        valid_opts
      end

    valid_opts =
      if(Map.has_key?(opts, "limit") and not is_nil(opts["limit"])) do
        case Integer.parse(opts["limit"]) do
          {limit, _} -> valid_opts ++ [limit: limit]
          :error -> valid_opts
        end
      else
        valid_opts
      end

    valid_opts = Keyword.merge(@pagination_defaults, valid_opts) |> Enum.into(%{})

    valid_opts =
      if(valid_opts.limit > valid_opts.max_limit) do
        %{valid_opts | limit: valid_opts.max_limit}
      else
        valid_opts
      end

    valid_opts
  end
end
