defmodule Embers.Feed.Public do
  @behaviour Embers.Feed

  import Ecto.Query
  import Embers.Feed.Utils

  alias Embers.Paginator
  alias Embers.Posts.Post

  @impl Embers.Feed
  def get(opts \\ []) do
    blocked_users = Keyword.get(opts, :blocked_users, [])
    blocked_tags = Keyword.get(opts, :blocked_tags, [])

    query =
      from(
        post in Post,
        where: post.nesting_level == 0 and is_nil(post.deleted_at),
        where: is_nil(post.related_to_id),
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        preload: [:tags, :reactions, :links, :media, user: {user, meta: meta}]
      )
      |> maybe_block_users(blocked_users)

    query
    |> Paginator.paginate(opts)
    |> load_avatars()
    |> fill_nsfw()
    |> remove_blocked_tags_posts(blocked_tags)
  end

  defp maybe_block_users(query, []), do: query

  defp maybe_block_users(query, blocked_users) do
    from(
      p in query,
      left_join: user in assoc(p, :user),
      where: user.id not in ^blocked_users
    )
  end

  defp remove_blocked_tags_posts(page, []), do: page

  defp remove_blocked_tags_posts(page, blocked_tags) do
    blocked_tags = Enum.map(blocked_tags, &String.downcase/1)
    entries = page.entries

    entries =
      entries
      |> Enum.reject(fn post ->
        Enum.any?(post.tags, fn tag -> String.downcase(tag.name) in blocked_tags end)
      end)

    %{page | entries: entries}
  end
end
