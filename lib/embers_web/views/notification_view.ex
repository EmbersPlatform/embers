defmodule EmbersWeb.NotificationView do
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
      text: notification.text,
      read: notification.read,
      inserted_at: notification.inserted_at,
      source_id: encode_id(notification.source_id)
    }
    |> handle_from(notification)
  end

  defp handle_from(view, notification) do
    if(Ecto.assoc_loaded?(notification.from)) do
      user = render_one(notification.from, EmbersWeb.UserView, "user.json")
      Map.put(view, "from", user)
    end || view
  end

  defp encode_id(id) when is_nil(id), do: nil

  defp encode_id(id) do
    IdHasher.encode(id)
  end
end
