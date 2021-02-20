defmodule EmbersWeb.TagPinnedController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Subscriptions.Tags

  plug(:user_check)

  def list_pinned(conn, _params) do
    user = conn.assigns.current_user
    pinned_tags = Tags.list_pinned(user.id)

    conn
    |> render("list_pinned.json", tags: pinned_tags)
  end
end
