defmodule Embers.Notifications.Manager do
  @moduledoc false

  use GenServer
  use Embers.PubSubBroadcaster

  require Logger

  import Ecto.Query

  alias Embers.Posts
  alias Embers.Posts.Post
  alias Embers.Blocks
  alias Embers.Notifications
  alias Embers.Repo

  @type events ::
          {:notification, :created}
          | {:notification, :create_failed}
          | {:user_mentioned}

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl GenServer
  def init(init_arg) do
    __MODULE__.subscribe()
    Posts.subscribe()
    Embers.Subscriptions.subscribe()

    {:ok, init_arg}
  end

  @doc false
  @impl GenServer
  def handle_info({Posts, {:post, :created}, post}, state) do
    handle_mentions(post)
    handle_comment(post)

    {:noreply, state}
  end

  def handle_info({__MODULE__, {:user_mentioned}, event}, state) do
    unless Blocks.blocked?(event.from, event.recipient) do
      case Notifications.create_notification(%{
             type: "mention",
             from_id: event.from,
             recipient_id: event.recipient,
             source_id: event.source
           }) do
        {:ok, notification} ->
          notification = notification |> Embers.Repo.preload(from: :meta)
          broadcast({:notification, :created}, notification)

        {:error, reason} ->
          broadcast({:notification, :create_failed}, reason)
      end
    end

    {:noreply, state}
  end

  def handle_info({Embers.Subscriptions, {:user, :followed}, event}, state) do
    if not Blocks.blocked?(event.from, event.recipient) do
      case Notifications.create_notification(%{
             type: "follow",
             from_id: event.from,
             recipient_id: event.recipient,
             source_id: event.from
           }) do
        {:ok, notification} ->
          notification = notification |> Embers.Repo.preload(from: :meta)
          broadcast({:notification, :created}, notification)

        {:error, reason} ->
          broadcast({:notification, :create_failed}, reason)
      end
    end

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp handle_mentions(%Post{body: body} = post) when not is_nil(body) do
    mentions = extract_mentions(body) |> Enum.map(&String.downcase/1)

    recipients =
      Repo.all(
        from(
          user in Embers.Accounts.User,
          where: user.canonical in ^mentions,
          select: user.id
        )
      )

    # don't notify the user that mentioned himself
    recipients =
      recipients
      |> Enum.reject(fn recipient -> recipient == post.user_id end)

    # don't notify recipients that blocked the user
    blocking_users = Embers.Blocks.list_users_ids_that_blocked(post.user_id)
    recipients = Enum.reject(recipients, fn recipient -> recipient in blocking_users end)

    recipients = remove_self_from_recipients(recipients, post)

    create_mention_notifications(recipients, post)
  end

  defp handle_mentions(_), do: :ok

  defp maybe_preload_post_parent(post) do
    unless Ecto.assoc_loaded?(post.parent) do
      Repo.preload(post, :parent)
    end || post
  end

  defp remove_self_from_recipients(recipients, post) do
    unless is_nil(post.parent_id) do
      post = maybe_preload_post_parent(post)
      Enum.reject(recipients, fn recipient -> recipient == post.parent.user_id end)
    end || recipients
  end

  defp extract_mentions(body) do
    regex = ~r/(?<![\w.-])@([-\w]*(?:\w+)*)(?!\S)/

    regex
    |> Regex.scan(body)
    |> Enum.map(fn [_, txt] -> txt end)
  end

  defp create_mention_notifications(recipients, post) do
    recipients
    |> Enum.each(fn recipient ->
      broadcast({:user_mentioned}, %{
        from: post.user_id,
        recipient: recipient,
        source: post.id
      })
    end)
  end

  defp handle_comment(%{parent_id: nil}), do: :noop

  defp handle_comment(post) do
    with {:ok, parent} <- Posts.get_post(post.parent_id) do
      if parent.user_id != post.user_id do
        {:ok, notification} =
          Notifications.create_notification(%{
            type: "comment",
            from_id: post.user_id,
            recipient_id: parent.user_id,
            source_id: parent.id
          })

        notification = notification |> Embers.Repo.preload(from: :meta)
        broadcast({:notification, :created}, notification)
      end
    end
  end
end
