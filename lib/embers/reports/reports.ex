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

  use Embers.PubSubBroadcaster

  import Ecto.Query

  alias Embers.Repo
  alias Embers.Reports.Report
  alias Embers.Reports.Reportable
  alias Embers.Paginator

  def report(reportable, reporter, params) do
    case Reportable.report(reportable, reporter, params) do
      {:ok, report} = res ->
        broadcast([:report, :created], report)
        res

      res ->
        res
    end
  end

  def reports_for(reportable, opts \\ []) do
    Reportable.reports_for(reportable, opts)
  end

  def resolve(report) do
    Report.resolve(report)
    broadcast([:report, :resolved], report.post_id)
    :ok
  end

  def open(report) do
    Report.open(report)
  end

  @spec most_common_comments_for(struct()) :: String.t()
  def most_common_comments_for(reportable) do
    from(r in Embers.Reports.PostReport,
      where: r.post_id == ^reportable.id,
      where: not r.resolved,
      where: not is_nil(r.comments),
      group_by: r.comments,
      select: r.comments,
      order_by: [desc: fragment("count(?)", r.id)],
      limit: 1
    )
    |> Repo.one()
  end

  @type report_reasons :: %{reporter: Embers.Accounts.User.t(), comments: [String.t()]}
  @spec get_comments_per_user(struct(), Keyword.t()) :: Paginator.Page.t(report_reasons())
  def get_comments_per_user(reportable, opts \\ []) do
    page =
      from(r in Embers.Reports.PostReport,
        where: r.post_id == ^reportable.id and not r.resolved,
        order_by: [desc: r.inserted_at],
        preload: [:reporter]
      )
      |> Paginator.paginate(opts)

    page =
      update_in(page.entries, fn entries ->
        entries
        |> Enum.group_by(
          fn x -> x.reporter end,
          fn x -> x.comments end
        )
        |> Enum.map(fn {reporter, comments} -> %{reporter: reporter, comments: comments} end)
      end)

    page
  end

  @spec resolve(struct()) :: :ok
  def resolve_for(reportable) do
    from(r in Embers.Reports.PostReport,
      where: r.post_id == ^reportable.id and not r.resolved,
      update: [set: [resolved: true]]
    )
    |> Repo.update_all([])

    broadcast([:report, :resolved], reportable.id)

    :ok
  end

  @spec count_unresolved_reports() :: integer()
  def count_unresolved_reports() do
    from(r in Embers.Reports.PostReport,
      where: not r.resolved,
      select: count(r.post_id, :distinct)
    )
    |> Repo.one()
  end

  @spec prune_reports() :: integer()
  def prune_reports do
    {count, _} =
      from(r in Embers.Reports.PostReport,
        inner_join: post in assoc(r, :post),
        where: r.resolved == true or not is_nil(post.deleted_at)
      )
      |> Repo.delete_all()

    broadcast([:reports, :pruned], nil)

    count
  end
end
