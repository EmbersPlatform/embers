defmodule EmbersWeb.Web.TagSubscriptionController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Subscriptions.Tags

  plug(:user_check)

  def index(conn, _params) do
    render("index.html")
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
      |> put_status(:no_content)
      |> json(nil)
    end
  end

  def unsubscribe(conn, %{"tag_id" => tag_id}) do
    user_id = conn.assigns.current_user.id

    Tags.delete_subscription(user_id, tag_id)

    conn
    |> put_status(:no_content)
    |> json(nil)
  end
end