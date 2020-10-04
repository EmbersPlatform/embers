defmodule EmbersWeb.Web.DiscoverController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Feed.Public

  plug(:user_check)

  action_fallback(EmbersWeb.FallbackController)

  def index(conn, params) do
    # TODO This should be changed to get a list of blocked tags instead of a page

    posts =
      case conn.assigns.current_user do
        nil -> posts_for_guests(params)
        user -> posts_for_user(user, params)
      end

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(posts)
      |> render("entries.html", posts: posts)
    else
      conn
      |> render("index.html", page_title: gettext("Discover"), posts: posts)
    end
  end

  defp posts_for_guests(params) do
    Public.get(
      after: params["after"],
      before: params["before"],
      limit: params["limit"],
      blocked_tags: ["nsfw"]
    )
  end

  defp posts_for_user(user, params) do
    blocked_users = Embers.Blocks.list_users_blocked_ids_by(user.id)

    # TODO This should be changed to get a list of blocked tags instead of a page
    %{entries: blocked_tags} = Embers.Subscriptions.Tags.list_blocked_tags_paginated(user.id)

    blocked_tags = blocked_tags |> Enum.map(fn x -> String.downcase(x.name) end)

    Public.get(
      after: params["after"],
      before: params["before"],
      limit: params["limit"],
      blocked_users: blocked_users,
      blocked_tags: blocked_tags
    )
  end
end
