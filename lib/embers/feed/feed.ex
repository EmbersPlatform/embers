defmodule Embers.Feed do
  @moduledoc """
  El modulo para interactuar con los feeds
  """

  import Ecto.Query
  alias Embers.Feed.Activity
  alias Embers.Paginator
  alias Embers.Posts.Post
  alias Embers.Repo

  def get_public(opts \\ []) do
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

  def get_timeline(user_id, opts \\ []) do
    query =
      from(
        activity in Activity,
        where: activity.user_id == ^user_id,
        left_join: post in assoc(activity, :post),
        where: is_nil(post.deleted_at),
        order_by: [desc: activity.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        preload: [
          post: {
            post,
            user: {user, meta: meta}
          }
        ],
        preload: [
          post: [
            :media,
            :links,
            :tags,
            :reactions,
            related_to: [:media, :tags, :links, :reactions, user: :meta]
          ]
        ]
      )

    query
    |> Paginator.paginate(opts)
    |> activities_to_posts()
    |> fill_nsfw()
  end

  def get_user_activities(user_id, opts \\ []) do
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

  @doc """
  Devuelve los posts agrupados por los tags

  Opciones:
  - `limit`: La cantidad de posts por tag
  """
  def get_by_tags(tags, opts \\ []) when is_list(tags) do
    limit = Keyword.get(opts, :limit, 10)

    Enum.reduce(tags, %{}, fn tag, acc ->
      query =
        from(
          post in Post,
          where: is_nil(post.deleted_at),
          where: is_nil(post.related_to_id),
          left_join: tag in assoc(post, :tags),
          where: tag.name == ^tag,
          order_by: [desc: post.id],
          left_join: user in assoc(post, :user),
          left_join: meta in assoc(user, :meta),
          preload: [
            [:media, :links, :reactions, :tags]
          ],
          preload: [
            user: {user, meta: meta}
          ],
          limit: ^limit
        )

      results =
        query
        |> Repo.all()
        |> Enum.map(fn post -> Post.fill_nsfw(post) end)

      Map.put(acc, tag, results)
    end)
  end

  def delete_activity(%Activity{} = activity) do
    with {:ok, activity} <- Repo.delete(activity) do
      Embers.Event.emit(:activity_deleted, activity)
      {:ok, activity}
    else
      error -> {:error, error}
    end
  end

  def delete_activity(user_id, post_id) do
    activity = Repo.get_by!(Activity, user_id: user_id, post_id: post_id)
    delete_activity(activity)
  end

  @doc """
  Crea las actividades para los recipientes
  """
  def push_acitivity(post, recipients \\ []) do
    activities =
      Enum.map(recipients, fn elem ->
        %{user_id: elem, post_id: post.id}
      end)

    Repo.insert_all(Activity, activities)
  end

  defp activities_to_posts(page) do
    %{page | entries: Enum.map(page.entries, fn a -> a.post end)}
  end

  defp fill_nsfw(page) do
    %{
      page
      | entries: Enum.map(page.entries, fn post -> Post.fill_nsfw(post) end)
    }
  end
end
