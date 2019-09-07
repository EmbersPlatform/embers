defmodule Embers.Feed.User do
  @behaviour Embers.Feed

  import Ecto.Query
  import Embers.Feed.Utils

  alias Embers.Paginator
  alias Embers.Posts.Post

  @impl Embers.Feed
  def get(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)

    query =
      from(
        post in Post,
        where: post.user_id == ^user_id,
        where: is_nil(post.deleted_at),
        where: post.nesting_level == 0,
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [
          [:media, :links, :reactions, :tags, related_to: [:media, :links, :tags, :reactions]]
        ],
        preload: [
          user: {user, meta: meta},
          related_to: {
            related,
            user: {
              related_user,
              meta: related_user_meta
            }
          }
        ]
      )

    query
    |> Paginator.paginate(opts)
    |> fill_nsfw()
  end
end
