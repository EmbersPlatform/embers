defmodule EmbersWeb.ModSubscriber do
  @moduledoc false
  use GenServer

  alias Embers.Reports

  def start_link(defaults) when is_list(defaults) do
    GenServer.start_link(__MODULE__, defaults)
  end

  def init(init_args) do
    Reports.subscribe()

    {:ok, init_args}
  end

  def handle_info({Reports, [:report, :created], _}, state) do
    broadcast_report_count()
    {:noreply, state}
  end

  def handle_info({Reports, [:report, :resolved], _}, state) do
    broadcast_report_count()
    {:noreply, state}
  end

  def handle_info({Reports, [:reports, :created], _}, state) do
    broadcast_report_count()
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  def broadcast_report_count() do
    count = Reports.count_unresolved_reports()

    EmbersWeb.Endpoint.broadcast!(
      "mod",
      "report_count_update",
      %{count: count}
    )
  end
end
