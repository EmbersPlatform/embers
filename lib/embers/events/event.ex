defmodule Embers.Event do
  @moduledoc """
  Este es un wrapper alrededir de los eventos de la librería `EventBus`.
  Su función es evitar tener que crear un evento de `EventBus` y enviarlo
  a mano porque resulta demasiado tedioso.
  """
  @doc """
  Crea un evento `EventBus.Model.Event` y notifica a `EventBus` del mismo.
  """
  def emit(topic, data) do
    event = struct(EventBus.Model.Event, %{topic: topic, data: data, id: Ecto.UUID.generate()})
    EventBus.notify(event)
  end
end
