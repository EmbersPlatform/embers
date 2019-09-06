defmodule Embers.Audit do
  # TODO document

  import Ecto.Query

  alias Embers.AuditDetail, as: Detail
  alias Embers.AuditEntry, as: Entry
  alias Embers.Repo

  def list(opts \\ []) do
    action = Keyword.get(opts, :action)
    query = from(entry in Entry, preload: [:user], order_by: [desc: entry.inserted_at])

    query =
      if action do
        from(entry in query, where: entry.action == ^action)
      end || query

    Repo.paginate(query, opts)
  end

  def get(id) when is_integer(id) do
    Repo.get(Entry, id)
  end

  def create(attrs) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
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
end
