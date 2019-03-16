defmodule Embers.Event do
  def emit(topic, data) do
    event = struct(EventBus.Model.Event, %{topic: topic, data: data, id: Ecto.UUID.generate()})
    EventBus.notify(event)
  end
end
