defmodule EmbersWeb.FeedController do
  use EmbersWeb, :controller

  alias Embers.Feed
  alias Embers.Feed.Post

  import Ecto.Query, warn: false
  alias Embers.Paginator
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
      from(
        post in Post,
        where: post.user_id == ^id and is_nil(post.deleted_at),
        where: post.nesting_level == 0,
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: media in assoc(post, :media),
        left_join: reactions in assoc(post, :reactions),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        left_join: related_tags in assoc(related, :tags),
        left_join: related_media in assoc(related, :media),
        preload: [
          user: {user, meta: meta},
          media: media,
          reactions: reactions,
          related_to: {
            related,
            user: {
              related_user,
              meta: related_user_meta
            },
            media: related_media,
            tags: related_tags
          }
        ]
      )
      |> Paginator.paginate(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end

  def get_public_feed(conn, params) do
    posts =
      from(
        post in Post,
        where: post.nesting_level == 0 and is_nil(post.deleted_at),
        where: is_nil(post.related_to_id),
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: media in assoc(post, :media),
        left_join: reactions in assoc(post, :reactions),
        preload: [
          user: {user, meta: meta},
          media: media,
          reactions: reactions
        ]
      )
      |> Paginator.paginate(
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "posts.json", posts)
  end
end
