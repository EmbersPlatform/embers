defmodule Embers.Repo do
  use Ecto.Repo, otp_app: :embers, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 20

  import Ecto.Query

  alias __MODULE__

  def soft_delete(query) do
    query
    |> Ecto.Changeset.change(
      deleted_at: Timex.now() |> Timex.to_naive_datetime() |> NaiveDateTime.truncate(:second)
    )
    |> __MODULE__.update()
  end

  def restore_entry(query) do
    query
    |> Ecto.Changeset.change(deleted_at: nil)
    |> __MODULE__.update()
  end

  def with_undeleted(query) do
    query
    |> where([t], is_nil(t.deleted_at))
  end

  @doc """
  Preloads *n* items per entity for the given association, similar to an `INNER JOIN LATERAL`,
  but using window functions.

      articles_list
      |> Repo.preload(:author)
      |> Repo.preload_lateral(:comments, limit: 5, assocs: [:author])

  ## Options
    - `:limit` (default: `2`) How many items to preload
    - `:order_by` A `{direction, field}` tuple to order the results
    - `:assocs` What to preload after items have been retrieved. It is directly passed to `Repo.preload`.
    - `:with_deleted?` When `true`, loads soft deleted records
  """
  def preload_lateral(entities, assoc, opts \\ [])
  def preload_lateral([], _, _), do: []

  def preload_lateral([%source_queryable{} | _] = entities, assoc, opts) do
    limit = Keyword.get(opts, :limit, 2)
    {order_direction, order_field} = Keyword.get(opts, :order_by, {:desc, :inserted_at})
    with_deleted? = Keyword.get(opts, :with_deleted?, false)

    fields = source_queryable.__schema__(:fields)

    %{
      related_key: related_key,
      queryable: assoc_queryable
    } = source_queryable.__schema__(:association, assoc)

    ids = Enum.map(entities, fn entity -> entity.id end)

    sub =
      from(
        p in assoc_queryable,
        where: p.parent_id in ^ids,
        select: map(p, ^fields),
        select_merge: %{
          _n:
            row_number()
            |> over(
              partition_by: field(p, ^related_key),
              order_by: [{^order_direction, field(p, ^order_field)}]
            )
        }
      )

    sub =
      unless with_deleted? do
        from(q in sub, where: is_nil(q.deleted_at))
      end || sub

    query =
      from(
        p in subquery(sub),
        where: p._n <= ^limit,
        select: p
      )

    preload_assocs = Keyword.get(opts, :assocs)

    results =
      Repo.all(query)
      |> results_to_struct(assoc_queryable)
      |> maybe_preload_assocs(preload_assocs)
      |> Enum.group_by(fn entity -> entity.parent_id end)

    add_results_to_entities(entities, assoc, results, opts)
  end

  defp results_to_struct(entities, s) do
    Enum.map(entities, fn x -> struct(s, x) end)
  end

  defp maybe_preload_assocs(entities, nil), do: entities

  defp maybe_preload_assocs(entities, assocs) do
    Repo.preload(entities, assocs)
  end

  defp add_results_to_entities(entities, assoc, results, opts) do
    Enum.map(entities, fn entity ->
      reverse? = Keyword.get(opts, :reverse, false)
      current_results = Map.get(results, entity.id, [])
      current_results = if reverse?, do: Enum.reverse(current_results), else: current_results
      Map.put(entity, assoc, current_results)
    end)
  end
end
