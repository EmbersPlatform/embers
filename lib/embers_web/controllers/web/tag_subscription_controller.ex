defmodule EmbersWeb.Web.TagSubscriptionController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Subscriptions.Tags

  plug(:user_check)

  def index(conn, _params) do
    user = conn.assigns.current_user
    pinned_tags = Tags.list_pinned(user.id)

    render(conn, "index.html", tags: pinned_tags)
  end

  def subscribe(conn, %{"tag_id" => tag_id} = params) do
    user_id = conn.assigns.current_user.id
    level = Map.get(params, "level")

    with Tags.create_or_update_subscription(%{
           user_id: user_id,
           source_id: tag_id,
           level: level
         }) do
      conn
      |> json(nil)
    end
  end

  def unsubscribe(conn, %{"tag_id" => tag_id}) do
    user_id = conn.assigns.current_user.id

    Tags.delete_subscription(user_id, tag_id)

    conn
    |> json(nil)
  end
end
