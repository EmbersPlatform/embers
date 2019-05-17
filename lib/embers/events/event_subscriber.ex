defmodule Embers.EventSubscriber do
  @moduledoc """
  Esta es la plantilla para los módulos que deseen escuchar a los eventos de
  `EventBus`.

  Primero se debe usar la plantilla para tener todas sus funciones.
  En `EventBus`, los nombres de los eventos son llamados `topics`. Para
  poder escuchar a estos topics, se debe indicar la lista de topics a
  escuchar al usar el modulo:
      use Embers.EventSubscriber, topics: ~w(post_created)

  Luego, se registra el módulo al iniciar la aplicación, lo ideal es hacerlo en
  `/lib/embers/application.ex`:

      def start(_type, _args) do
        # ...
        MyModule.register()
      end

  Ahora que nuestro módulo ya está registrado y puede escuchar topics, queda
  definir las funciones que se encargan de procesar los eventos:
      def handle_event(:post_created, event) do
        # Hacer algo con el evento
      end
  """
  defmacro __using__(opts) do
    topics = Keyword.get(opts, :topics, [])

    quote do
      def register do
        EventBus.subscribe({__MODULE__, unquote(topics)})
      end

      def process(event_shadow) do
        event = EventBus.fetch_event(event_shadow)

        Task.Supervisor.start_child(TaskSupervisor, fn ->
          handle_event(__MODULE__, event.topic, event)
        end)
      end

      def handle_event(mod, topic, event) do
        mod.handle_event(topic, event)
      end

      def complete_event(event) do
        EventBus.mark_as_completed({__MODULE__, {event.topic, event.id}})
      end
    end
  end
end
