defmodule EmbersWeb.Web.TimelineController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Feed.Timeline
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:show, :hide_activity])

  action_fallback(EmbersWeb.FallbackController)

  def index(conn, params) do
    user_id = get_in(conn, [:assigns, :current_user])

    results =
      Timeline.get(
        user_id: user_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "timeline.json", results)
  end
end
