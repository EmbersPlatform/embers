defmodule EmbersWeb.NotificationSubscriber do
  @moduledoc false

  use Embers.EventSubscriber,
    topics:
      ~w(notification_created post_reacted comment_reacted notification_read all_notifications_read)

  alias EmbersWeb.Web.NotificationView
  alias Embers.Profile.Meta

  require Logger

  def handle_event(:notification_created, event) do
    notification = event.data
    recipient = notification.recipient_id

    Logger.info("Sending ws notification to #{recipient}")

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      NotificationView.render("notification.json", %{
        notification: %{notification | status: 0}
      })
    )
  end

  def handle_event(:post_reacted, %{data: %{reaction: reaction}} = _event) do
    reaction = Embers.Repo.preload(reaction, user: :meta)

    reaction = %{
      reaction
      | user: %{reaction.user | meta: reaction.user.meta |> Meta.load_avatar_map()}
    }

    recipient = reaction.post.user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      %{
        ephemeral: true,
        type: "post_reaction",
        post_id: reaction.post_id,
        from: reaction.user.username,
        reaction: reaction.name,
        avatar: reaction.user.meta.avatar.small
      }
    )
  end

  def handle_event(:comment_reacted, %{data: %{reaction: reaction}} = _event) do
    reaction = Embers.Repo.preload(reaction, user: :meta)

    reaction = %{
      reaction
      | user: %{
          reaction.user
          | meta: Meta.load_avatar_map(reaction.user.meta)
        }
    }

    recipient = reaction.post.user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      %{
        ephemeral: true,
        type: "post_reaction",
        post_id: reaction.post_id,
        from: reaction.user.username,
        reaction: reaction.name,
        avatar: reaction.user.meta.avatar.small
      }
    )
  end

  def handle_event(:notification_read, %{data: notification}) do
    recipient = notification.user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification_read",
      %{id: notification.id}
    )
  end

  def handle_event(:all_notifications_read, %{data: user_id}) do
    IO.inspect("NOTIFICATIONS READ FOR #{user_id}")
    recipient = user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "all_notifications_read",
      %{}
    )
  end
end
