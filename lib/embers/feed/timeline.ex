defmodule Embers.Feed.Timeline do
  @behaviour Embers.Feed

  use Embers.PubSubBroadcaster

  import Ecto.Query
  import Embers.Feed.Utils

  alias Embers.Feed.Activity
  alias Embers.Paginator
  alias Embers.Repo

  @impl Embers.Feed
  @doc """
    ## Options
      - `:user_id` the id of the timeline's user
      - `:with_replies` the ammount of replies to load per post, or 0 if `false`
  """
  def get(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)

    query =
      from(
        activity in Activity,
        inner_join: post in assoc(activity, :post),
        on: is_nil(post.deleted_at),
        left_join: related_to in assoc(post, :related_to),
        where: activity.user_id == ^user_id,
        where: is_nil(related_to.deleted_at) or not is_nil(post.body),
        order_by: [desc: activity.id],
        preload: [
          post: {
            post,
            related_to: related_to
          }
        ],
        preload: [
          post: [
            :media,
            :links,
            :tags,
            :reactions,
            user: [:meta],
            related_to: [:media, :tags, :links, :reactions, user: :meta]
          ]
        ]
      )

    query
    |> Paginator.paginate(opts)
    |> activities_to_posts()
    |> maybe_with_replies(opts)
    |> order_replies()
    |> load_avatars()
    |> fill_nsfw()
    |> Embers.Feed.group_shares()
  end

  defp maybe_with_replies(page, opts) do
    with_replies = Keyword.get(opts, :with_replies, false)

    if with_replies do
      entries =
        page.entries
        |> Repo.preload_lateral(:replies,
          limit: 2,
          assocs: [:media, :links, :reactions, user: [:meta]]
        )

      put_in(page.entries, entries)
    end || page
  end

  defp order_replies(page) do
    update_in(page.entries, fn entries ->
      Enum.map(entries, fn entry ->
        if Ecto.assoc_loaded?(entry.replies) do
          update_in(entry.replies, &Enum.reverse/1)
        else
          entry
        end
      end)
    end)
  end

  @doc """
  Deletes an activity
  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
    |> broadcast_result([:activity, :deleted])
  end

  @doc """
  Removes an activity
  """
  def delete_activity(user_id, post_id) do
    activity = Repo.get_by!(Activity, user_id: user_id, post_id: post_id)
    delete_activity(activity)
  end

  @doc """
  Creates an activity for each recipient
  """
  def push_activity(post, recipients \\ []) do
    activities =
      Enum.map(recipients, fn elem ->
        %{user_id: elem, post_id: post.id}
      end)

    Repo.insert_all(Activity, activities)
  end

  defp activities_to_posts(page) do
    %{page | entries: Enum.map(page.entries, fn a -> a.post end)}
  end
end
