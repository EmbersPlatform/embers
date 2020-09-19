defprotocol Embers.Reports.Reportable do
  @doc "Reporta a un reportable(ej: Post, User)"
  def report(reportable, reporter, params)

  def reports_for(reportable, opts \\ [])
end

defprotocol Embers.Reports.Report do
  @doc "Marca un reporte como resuelto"
  def resolve(report)

  def open(report)
end

defmodule Embers.Reports do
  @moduledoc """
  Tambien conocidos como denuncias, los reportes se generan cuando un
  usuario quiere dar aviso al staff de contenido que infringe las reglas
  del sitio.

  Ejemplos de reportables son los Posts.
  """

  import Ecto.Query

  alias Embers.Repo
  alias Embers.Reports.Report
  alias Embers.Reports.Reportable

  def report(reportable, reporter, params) do
    Reportable.report(reportable, reporter, params)
  end

  def reports_for(reportable, opts \\ []) do
    Reportable.reports_for(reportable, opts)
  end

  def resolve(report) do
    Report.resolve(report)
  end

  def open(report) do
    Report.open(report)
  end

  @spec most_common_comments_for(struct()) :: String.t()
  def most_common_comments_for(reportable) do
    from(r in Embers.Reports.PostReport,
      where: r.post_id == ^reportable.id and not r.resolved,
      group_by: r.comments,
      select: r.comments,
      order_by: [desc: fragment("count(?)", r.id)],
      limit: 1
    )
    |> Repo.one()
  end

  @spec resolve(struct()) :: :ok
  def resolve_for(reportable) do
    from(r in Embers.Reports.PostReport,
      where: r.post_id == ^reportable.id and not r.resolved,
      update: [set: [resolved: true]]
    )
    |> Repo.update_all([])

    :ok
  end

  @spec count_unresolved_reports() :: integer()
  def count_unresolved_reports() do
    from(r in Embers.Reports.PostReport,
      distinct: r.post_id,
      where: not r.resolved,
      select: count(r.id)
    )
    |> Repo.one()
  end

  @spec prune_reports() :: integer()
  def prune_reports do
    {count, _} =
      from(r in Embers.Reports.PostReport,
        inner_join: post in assoc(r, :post),
        where: (r.resolved == true or not is_nil(post.deleted_at))
      )
      |> Repo.delete_all()
    count
  end
end
