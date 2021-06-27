defmodule Embers.Audit do
  # TODO document

  import Ecto.Query

  use Embers.PubSubBroadcaster

  alias Embers.AuditDetail, as: Detail
  alias Embers.AuditEntry, as: Entry
  alias Embers.Repo

  @type events :: {:audit, :created}
  @type post_and_actor :: %{post: term, actor: term}

  @spec list_entries(opts :: keyword()) :: Embers.Paginator.Page.t(Entry.t())
  def list_entries(opts \\ []) do
    from(entry in Entry,
      order_by: [desc: entry.inserted_at],
      preload: [:user]
    )
    |> maybe_filter_by_action(opts)
    |> Embers.Paginator.paginate(opts)
  end

  defp maybe_filter_by_action(query, opts) do
    action = Keyword.get(opts, :action)

    if action do
      from(entry in query, where: entry.action == ^action)
    else
      query
    end
  end

  def get(id) when is_integer(id) do
    Repo.get(Entry, id)
  end

  def create(attrs) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
    |> broadcast_result({:audit, :created})
  end

  def add_detail(%Entry{} = entry, detail_attrs) do
    detail =
      %Detail{}
      |> Detail.changeset(detail_attrs)

    details = entry.details ++ [detail]

    entry
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:details, details)
    |> Repo.update()
  end

  @doc """
  Deletes all audit entries except the last `n`

  ## Options
  - `keep`: how many entries to keep. Default: `20`
  """
  @spec prune(keyword()) :: {:ok, integer()}
  def prune(opts \\ []) do
    keep = Keyword.get(opts, :keep, 20)

    last_date = get_last_keepable_entry_date(keep)

    {affected, _} =
      from(entry in Entry,
        where: entry.inserted_at < ^last_date
      )
      |> Repo.delete_all()

    {:ok, affected}
  end

  defp get_last_keepable_entry_date(keep) do
    entry =
      from(entry in Entry,
        order_by: [desc: entry.inserted_at],
        limit: ^keep
      )
      |> Repo.all()
      |> List.last()

    case entry do
      nil -> NaiveDateTime.utc_now()
      entry -> entry.inserted_at
    end
  end
end
