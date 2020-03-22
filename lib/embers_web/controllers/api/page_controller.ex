defmodule EmbersWeb.Api.PageController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Subscriptions

  action_fallback(EmbersWeb.Web.FallbackController)

  def auth(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) when not is_nil(user) do
    tags = Subscriptions.Tags.list_subscribed_tags(user.id)

    render(conn, "auth.json", conn: conn, tags: tags, user: user)
  end

  def auth(conn, _params) do
    render(conn, "auth.json", conn: conn)
  end
end
