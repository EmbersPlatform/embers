defmodule Embers.Feed do
  @moduledoc """
  The Feed context.
  """

  import Ecto.Query, warn: false
  alias Embers.Repo
  alias Embers.Paginator
  alias Ecto.Multi

  alias Embers.Feed.{Post, Activity}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get(Post, id) |> Repo.preload(:user)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    post_changeset = Post.changeset(%Post{}, attrs)

    Multi.new()
    |> Multi.insert(:post, post_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{post: post} = _results} ->
        # Asynchronously create activity entries
        Task.Supervisor.start_child(Embers.Feed.FeedSupervisor, fn ->
          create_activity_for_post(post)
        end)

        {:ok, post}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  def get_timeline(user_id, opts) do
    Activity
    |> where([activity], activity.user_id == ^user_id)
    |> order_by([activity], desc: activity.id)
    |> join(:left, [activity], post in assoc(activity, :post))
    |> join(:left, [activity, post], user in assoc(post, :user))
    |> join(:left, [activity, post, user], meta in assoc(user, :meta))
    |> preload(
      [activity, post, user, meta],
      post: {post, user: {user, meta: meta}}
    )
    |> Paginator.paginate(opts)
  end

  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  defp create_activity_for_post(post) do
    # Get the recipients the activity will be added to
    users_query =
      from(
        us in "user_subscriptions",
        where: us.source_id == ^post.user_id,
        select: [:user_id]
      )

    users = Repo.all(users_query)
    # [%{user_id: integer}, ...]

    # Add post owner to recipients
    recipients = users ++ [%{user_id: post.user_id}]

    # Create a map with the required attrs to create the activity entry
    activities_maps =
      Enum.map(recipients, fn elem ->
        # Append the post id
        Map.put(elem, :post_id, post.id)
      end)

    Repo.insert_all(Activity, activities_maps)
  end
end
