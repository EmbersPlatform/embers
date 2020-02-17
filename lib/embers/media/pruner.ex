defmodule Embers.Media.Pruner do
  # It gave an error on production that I didn't document, so this module
  # should be reviewed and probably rewritten.
  use GenServer

  require Logger

  alias Embers.Media

  @tick_interval :timer.hours(1)

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, Embers.MediaPruner)
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(state) do
    Logger.info("MEDIA PRUNER Media pruner service started")
    prune()
    {:ok, state}
  end

  def handle_info(:prune, state) do
    prune()
    {:noreply, state}
  end

  defp prune do
    count = Media.get_expired() |> Enum.count()
    Logger.info("MEDIA PRUNER Pruning #{inspect(count)} medias...")
    Media.prune()
    Logger.info("MEDIA PRUNER Media pruning finished.")
    reschedule()
  end

  defp reschedule do
    {:ok, next_pruning} =
      Timex.now()
      |> Timex.shift(milliseconds: @tick_interval)
      |> Timex.Format.DateTime.Formatter.format("{RFC822}")

    Logger.info("MEDIA PRUNER Next pruning #{next_pruning}")
    tick()
  end

  defp tick, do: Process.send_after(self(), :prune, @tick_interval)
end
