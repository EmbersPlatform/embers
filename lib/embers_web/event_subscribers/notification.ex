defmodule EmbersWeb.NotificationSubscriber do
  use Embers.EventSubscriber, topics: ~w(notification_created)

  alias Embers.Helpers.IdHasher
  alias EmbersWeb.NotificationView

  require Logger

  def handle_event(:notification_created, event) do
    notification = event.data
    recipient = IdHasher.encode(notification.recipient_id)

    Logger.info("Sending ws notification to #{recipient}")

    EmbersWeb.Endpoint.broadcast!(
      "user:#{recipient}",
      "notification",
      NotificationView.render("notification.json", %{notification: %{notification | status: 0}})
    )
  end
end
