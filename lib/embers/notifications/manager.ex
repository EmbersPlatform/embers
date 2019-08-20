defmodule Embers.Notifications.Manager do
  @moduledoc """
  Este es el modulo que se encarga de crear y enviar notificaciones a los
  usuarios.

  Basado en `Embers.EventSubscriber`, este módulo escucha a los eventos y
  realiza las acciones necesarias.
  """

  use Embers.EventSubscriber, topics: ~w(post_created post_comment user_mentioned user_followed)

  require Logger

  import Ecto.Query

  alias Embers.Posts
  alias Embers.Posts.Post
  alias Embers.Blocks
  alias Embers.Notifications
  alias Embers.Repo

  @doc false
  def handle_event(:post_created, event) do
    post = event.data
    handle_mentions(post)
    handle_comment(post)
  end

  def handle_event(:user_mentioned, event) do
    unless Blocks.blocked?(event.data.from, event.data.recipient) do
      case Notifications.create_notification(%{
             type: "mention",
             from_id: event.data.from,
             recipient_id: event.data.recipient,
             source_id: event.data.source
           }) do
        {:ok, notification} ->
          notification = notification |> Embers.Repo.preload(from: :meta)
          Embers.Event.emit(:notification_created, notification)

        {:error, reason} ->
          Embers.Event.emit(:create_notification_failed, reason)
      end
    end
  end

  def handle_event(:user_followed, event) do
    if not Blocks.blocked?(event.data.from, event.data.recipient) do
      case Notifications.create_notification(%{
             type: "follow",
             from_id: event.data.from,
             recipient_id: event.data.recipient,
             source_id: event.data.from
           }) do
        {:ok, notification} ->
          notification = notification |> Embers.Repo.preload(from: :meta)
          Embers.Event.emit(:notification_created, notification)

        {:error, reason} ->
          Embers.Event.emit(:create_notification_failed, reason)
      end
    end
  end

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
      Embers.Event.emit(:user_mentioned, %{
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
        Embers.Event.emit(:notification_created, notification)
      end
    end
  end
end
