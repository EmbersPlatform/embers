defmodule Embers.PubSubBroadcaster do
  @moduledoc """
  TODO document
  """

  @type result :: {:ok, term} | {:error, term}

  @doc """
  Subscribe the current process to this module events
  """
  @callback subscribe() :: :ok | {:error, term}

  @doc """
  Broadcasts an event to the pubsub in the shape `{namespace, event, payload}`.

  ## Example
      iex> subscribe()
      :ok
      iex> broadcast([:post, :created], %{id: "2k"})
      :ok
      iex> flush()
      {MyApp.PubSub, [:post, :created], %{id: "2k"}}
  """
  @callback broadcast(event :: term, payload :: term) :: :ok | {:error, term}

  @doc """
  If the first argument is a result tuple like `{:ok, value} | {:error, reason}`,
  `broadcast/2` will broadcast the event with the value from the ok tuple and
  bypass the error. In both cases the tuple will be returned untouched.

      Repo.insert(post)
      |> broadcast_result([:post, :created])
  """
  @callback broadcast_result(payload :: result, event :: term) :: result

  defmacro __using__(opts) do
    current_module =
      quote do
        inspect(__MODULE__)
      end

    topic = Keyword.get(opts, :topic, current_module)

    pubsub = Keyword.get(opts, :pubsub, Embers.PubSub)

    namespace = Keyword.get(opts, :namespace, current_module)

    quote do
      @behaviour Embers.PubSubBroadcaster

      @impl Embers.PubSubBroadcaster
      def subscribe() do
        Phoenix.PubSub.subscribe(unquote(pubsub), unquote(topic))
      end

      @impl Embers.PubSubBroadcaster
      def broadcast_result({:error, reason}, _event), do: {:error, reason}

      def broadcast_result({:ok, entity}, event) do
        broadcast(event, entity)

        {:ok, entity}
      end

      @impl Embers.PubSubBroadcaster
      def broadcast(event, payload) do
        Phoenix.PubSub.broadcast!(
          unquote(pubsub),
          unquote(topic),
          {unquote(namespace), event, payload}
        )
      end
    end
  end
end
