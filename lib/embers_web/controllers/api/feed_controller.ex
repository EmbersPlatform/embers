defmodule EmbersWeb.Api.FeedController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Feed.Public
  alias Embers.Feed.Timeline
  alias Embers.Feed.User, as: UserFeed

  plug(:user_check when action in [:timeline, :hide_post])

  plug(
    :rate_limit_feeds,
    [max_requests: 20, interval_seconds: 60]
    when action in [
           :timeline,
           :user_statuses,
           :get_public_feed
         ]
  )

  def rate_limit_feeds(conn, options \\ []) do
    ip = conn.remote_ip
    ip_string = ip |> :inet_parse.ntoa() |> to_string()
    options = Keyword.merge(options, bucket_name: "feed:#{ip_string}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def timeline(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    results =
      Timeline.get(
        user_id: user_id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "timeline.json", results)
  end

  def user_statuses(conn, %{"id" => id} = params) do
    posts =
      UserFeed.get(
        user_id: id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end

  @spec get_public_feed(Plug.Conn.t(), nil | keyword | map) :: Plug.Conn.t()
  def get_public_feed(%{assigns: %{current_user: user}} = conn, params) do
    blocked_users = Embers.Blocks.list_users_blocked_ids_by(user.id)

    %{entries: blocked_tags} = Embers.Subscriptions.Tags.list_blocked_tags_paginated(user.id)

    blocked_tags = blocked_tags |> Enum.map(fn x -> String.downcase(x.name) end)

    posts =
      Public.get(
        after: params["after"],
        before: params["before"],
        limit: params["limit"],
        blocked_users: blocked_users,
        blocked_tags: blocked_tags
      )

    render(conn, "posts.json", posts)
  end

  def get_public_feed(conn, params) do
    posts =
      Public.get(
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end

  def hide_post(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    with {:ok, _activity} <- Timeline.delete_activity(user.id, id) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end
end
