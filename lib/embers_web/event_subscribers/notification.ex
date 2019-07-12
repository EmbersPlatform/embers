defmodule EmbersWeb.NotificationSubscriber do
  use Embers.EventSubscriber, topics: ~w(notification_created post_reacted comment_reacted)

  import Embers.Helpers.IdHasher

  alias EmbersWeb.NotificationView
  alias Embers.Profile.Meta

  require Logger

  def handle_event(:notification_created, event) do
    notification = event.data
    recipient = encode(notification.recipient_id)

    Logger.info("Sending ws notification to #{recipient}")

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      NotificationView.render("notification.json", %{notification: %{notification | status: 0}})
    )
  end

  def handle_event(:post_reacted, %{data: %{reaction: reaction}} = _event) do
    reaction = Embers.Repo.preload(reaction, user: :meta)

    reaction = %{
      reaction
      | user: %{reaction.user | meta: reaction.user.meta |> Meta.load_avatar_map()}
    }

    recipient = encode(reaction.post.user_id)

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      %{
        ephemeral: true,
        type: "post_reaction",
        post_id: encode(reaction.post_id),
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
      | user: %{reaction.user | meta: reaction.user.meta |> Meta.load_avatar_map()}
    }

    recipient = encode(reaction.post.user_id)

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      %{
        ephemeral: true,
        type: "post_reaction",
        post_id: encode(reaction.post_id),
        from: reaction.user.username,
        reaction: reaction.name,
        avatar: reaction.user.meta.avatar.small
      }
    )
  end
end
