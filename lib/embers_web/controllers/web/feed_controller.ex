defmodule EmbersWeb.FeedController do
  use EmbersWeb, :controller

  alias Embers.Feed
  alias Embers.Helpers.IdHasher

  def timeline(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    results =
      Feed.get_timeline(user_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "timeline.json", results)
  end

  def user_statuses(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    posts =
      Feed.get_user_activities(
        id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end

  @spec get_public_feed(Plug.Conn.t(), nil | keyword | map) :: Plug.Conn.t()
  def get_public_feed(%{assigns: %{current_user: user}} = conn, params) do
    blocked_users = Embers.Feed.Subscriptions.Blocks.list_users_blocked_ids_by(user.id)

    %{entries: blocked_tags} =
      Embers.Feed.Subscriptions.Tags.list_blocked_tags_ids_paginated(user.id)

    posts =
      Feed.get_public(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"],
        blocked_users: blocked_users,
        blocked_tags: blocked_tags
      )

    render(conn, "posts.json", posts)
  end

  def get_public_feed(conn, params) do
    posts =
      Feed.get_public(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end
end
