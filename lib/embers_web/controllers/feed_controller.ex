defmodule EmbersWeb.FeedController do
  use EmbersWeb, :controller

  alias Embers.Feed
  alias Embers.Feed.Post

  import Ecto.Query, warn: false
  alias Embers.Paginator
  alias Embers.Helpers.IdHasher

  def timeline(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    results = Feed.get_timeline(user_id, params)

    render(conn, "timeline.json", results)
  end

  def get_public_feed() do
    :not_implemented
  end

  def user_statuses(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    posts =
      from(
        post in Post,
        where: post.user_id == ^id,
        where: post.nesting_level == 0,
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: media in assoc(post, :media),
        preload: [
          user: {user, meta: meta},
          media: media
        ]
      )
      |> Paginator.paginate(params)

    render(conn, "posts.json", posts)
  end

  def get_public_feed(conn, params) do
    posts =
      from(
        post in Post,
        where: post.nesting_level == 0,
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: media in assoc(post, :media),
        preload: [
          user: {user, meta: meta},
          media: media
        ]
      )
      |> Paginator.paginate(params)

    render(conn, "posts.json", posts)
  end
end
