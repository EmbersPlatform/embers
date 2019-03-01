defmodule Embers.Notifications.Manager do
  use Embers.EventSubscriber, topics: ~w(post_created post_comment user_mentioned)

  require Logger

  import Ecto.Query

  alias Embers.Notifications

  def handle_event(:post_created, event) do
    handle_mentions(event.data)
  end

  def handle_event(:post_comment, event) do
    if(event.data.from != event.data.recipient) do
      case Notifications.create_notification(%{
             type: "comment",
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

  def handle_event(:user_mentioned, event) do
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

  defp handle_mentions(%Embers.Feed.Post{body: body} = post) when not is_nil(body) do
    regex = ~r/(?:^|[^a-zA-Z0-9_＠!@#$%&*])(?:(?:@|＠)(?!\/))([a-zA-Z0-9_]{1,15})(?:\b(?!@|＠)|$)/
    results = Regex.scan(regex, body) |> Enum.map(fn [_, txt] -> txt end)

    recipients =
      from(
        user in Embers.Accounts.User,
        where: user.canonical in ^results,
        select: user.id
      )
      |> Embers.Repo.all()
      # don't notify the user that mentioned himself
      |> Enum.reject(fn recipient -> recipient == post.user_id end)

    recipients =
      if not is_nil(post.parent_id) do
        post =
          if !Ecto.assoc_loaded?(post.parent) do
            Embers.Repo.preload(post, :parent)
          end || post

        if Enum.member?(recipients, post.parent.user_id) do
          Enum.reject(recipients, fn recipient -> recipient == post.parent.user_id end)
        end
      end || recipients

    create_mention_notifications(recipients, post)
  end

  defp handle_mentions(_), do: :ok

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
end
