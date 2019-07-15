defmodule Embers.Feed.Timeline do
  @behaviour Embers.Feed

  import Ecto.Query
  import Embers.Feed.Utils

  alias Embers.Feed.Activity
  alias Embers.Paginator
  alias Embers.Repo

  @impl Embers.Feed
  def get(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)

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
end
