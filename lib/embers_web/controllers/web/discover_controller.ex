defmodule EmbersWeb.Web.DiscoverController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Feed.Public
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:index])

  action_fallback(EmbersWeb.FallbackController)

  def index(%{assigns: %{current_user: user}} = conn, params) do
    blocked_users = Embers.Blocks.list_users_blocked_ids_by(user.id)

    # TODO This should be changed to get a list of blocked tags instead of a page
    %{entries: blocked_tags} = Embers.Subscriptions.Tags.list_blocked_tags_paginated(user.id)

    blocked_tags = blocked_tags |> Enum.map(fn x -> String.downcase(x.name) end)

    posts =
      Public.get(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"],
        blocked_users: blocked_users,
        blocked_tags: blocked_tags
      )

    IO.inspect(params)

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(posts)
      |> render("entries.html", posts: posts)
    else
      conn
      |> render("index.html", posts: posts)
    end
  end
end
