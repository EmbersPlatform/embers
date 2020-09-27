defmodule EmbersWeb.ModSubscriber do
  @moduledoc false
  use Embers.EventSubscriber, topics: ~w(report_created report_resolved reports_pruned)

  alias Embers.Reports

  def handle_event(event, _data) when event in ~w(report_created report_resolved reports_pruned)a do
    count = Reports.count_unresolved_reports


    EmbersWeb.Endpoint.broadcast!(
      "mod",
      "report_count_update",
      %{count: count}
    )
  end
end
