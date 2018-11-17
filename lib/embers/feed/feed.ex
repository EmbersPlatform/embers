defmodule Embers.Feed do
  @moduledoc """
  The Feed context.
  """

  import Ecto.Query, warn: false
  alias Embers.Repo
  alias Embers.Paginator
  alias Ecto.Multi
  alias Embers.Helpers.IdHasher
  alias Embers.Media.MediaItem

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
  Gets a single post with preloaded user and meta.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    from(
      post in Post,
      where: post.id == ^id,
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      left_join: media in assoc(post, :media),
      preload: [
        user: {user, meta: meta},
        media: media
      ]
    )
    |> Repo.one()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs) do
    post_changeset = Post.changeset(%Post{}, attrs)

    Multi.new()
    |> Multi.insert(:post, post_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{post: post} = _results} ->
        if(post.nesting_level === 0) do
          # Asynchronously create activity entries
          Task.Supervisor.start_child(Embers.Feed.FeedSupervisor, fn ->
            create_activity_for_post(post)
          end)
        else
          # Update parent post replies count
          from(
            p in Post,
            where: p.id == ^post.parent_id,
            update: [inc: [replies_count: 1]]
          )
          |> Repo.update_all([])
        end

        if(Map.has_key?(attrs, "attachments")) do
          attachments = attrs["attachments"]

          ids = Enum.map(attachments, fn x -> IdHasher.decode(x["id"]) end)

          medias =
            from(m in MediaItem, where: m.id in ^ids)
            |> Repo.all()

          post
          |> Repo.preload(:media)
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_assoc(:media, medias)
          |> Repo.update()

          from(
            media in MediaItem,
            where: media.id in ^ids
          )
          |> Repo.update_all(set: [temporary: false])
        end

        {:ok, post |> Repo.preload(:media)}

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
    if post.nesting_level > 0 do
      # Update parent post replies count
      from(
        p in Post,
        where: p.id == ^post.parent_id,
        update: [inc: [replies_count: -1]]
      )
      |> Repo.update_all([])
    end

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
    from(
      activity in Activity,
      where: activity.user_id == ^user_id,
      order_by: [desc: activity.id],
      left_join: post in assoc(activity, :post),
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      left_join: media in assoc(post, :media),
      preload: [
        post: {post, user: {user, meta: meta}, media: media}
      ]
    )
    |> Paginator.paginate(opts)
  end

  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  def get_post_replies(parent_id, opts \\ %{}) do
    Post
    |> where([post], post.parent_id == ^parent_id)
    |> join(:left, [post], user in assoc(post, :user))
    |> join(:left, [post, user], meta in assoc(user, :meta))
    |> preload(
      [post, user, meta],
      user: {user, meta: meta}
    )
    |> Paginator.paginate(opts)
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
