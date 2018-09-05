defmodule EmbersWeb.FeedController do
  use EmbersWeb, :controller

  alias Embers.Feed

  def timeline(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    results = Feed.get_timeline(user_id, params)

    render(conn, "timeline.json", results)
  end
end
