defmodule EmbersWeb.Web.NotificationView do
  @moduledoc false
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("notifications.json", %{entries: notifications} = metadata) do
    %{
      items: render_many(notifications, __MODULE__, "notification.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("notification.json", %{notification: notification} = _assigns) do
    %{
      id: IdHasher.encode(notification.id),
      type: notification.type,
      from: notification.from.username,
      text: notification.text,
      status: notification.status,
      inserted_at: notification.inserted_at,
      source: encode_id(notification.source_id),
    }
  end
end
