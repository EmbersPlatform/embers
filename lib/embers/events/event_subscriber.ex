defmodule Embers.EventSubscriber do
  defmacro __using__(opts) do
    topics = Keyword.get(opts, :topics, [])

    quote do
      def register() do
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
