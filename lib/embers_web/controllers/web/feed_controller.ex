defmodule EmbersWeb.FeedController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Feed.Public
  alias Embers.Feed.Timeline
  alias Embers.Feed.User, as: UserFeed
  alias Embers.Helpers.IdHasher

  plug(:user_check when action in [:timeline, :hide_post])

  def timeline(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    results =
      Timeline.get(
        user_id: user_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "timeline.json", results)
  end

  def user_statuses(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    posts =
      UserFeed.get(
        user_id: id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
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
      Public.get(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end

  def hide_post(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    with {:ok, _activity} <- Timeline.delete_activity(user.id, IdHasher.decode(id)) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end
end
