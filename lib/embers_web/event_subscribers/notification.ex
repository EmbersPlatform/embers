defmodule EmbersWeb.NotificationSubscriber do
  @moduledoc false

  use GenServer

  alias EmbersWeb.NotificationView
  alias Embers.Profile.Meta

  require Logger

  def start_link(defaults) when is_list(defaults) do
    GenServer.start_link(__MODULE__, defaults)
  end

  def init(init_args) do
    Embers.Notifications.Manager.subscribe()
    Embers.Reactions.subscribe()
    Embers.Notifications.subscribe()
    EmbersWeb.NotificationController.subscribe()

    {:ok, init_args}
  end

  def handle_info({Embers.Notifications.Manager, [:notification, :created], notification}, state) do
    recipient = notification.recipient_id

    Logger.info("Sending ws notification to #{recipient}")

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      NotificationView.render("notification.json", %{
        notification: %{notification | status: 0}
      })
    )

    {:noreply, state}
  end

  def handle_info({Embers.Reactions, {:post_reacted}, reaction}, state) do
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

    {:noreply, state}
  end

  def handle_info({Embers.Reactions, [:comment_reacted], reaction}, state) do
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

    {:noreply, state}
  end

  def handle_info({EmbersWeb.NotificationController, [:notification, :read], notification}, state) do
    recipient = notification.user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification_read",
      %{id: notification.id}
    )

    {:noreply, state}
  end

  def handle_info({Embers.Notifications, [:notifications, :all_read], user_id}, state) do
    recipient = user_id

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "all_notifications_read",
      %{}
    )

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
