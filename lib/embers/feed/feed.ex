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

  @max_media_count 4

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
      as: :post,
      where: post.id == ^id and is_nil(post.deleted_at),
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      left_join: media in assoc(post, :media),
      left_join: reactions in assoc(post, :reactions),
      left_join: tags in assoc(post, :tags),
      left_join: related in assoc(post, :related_to),
      left_join: related_user in assoc(related, :user),
      left_join: related_user_meta in assoc(related_user, :meta),
      left_join: related_tags in assoc(related, :tags),
      left_join: related_media in assoc(related, :media),
      left_join: related_reactions in assoc(related, :reactions),
      preload: [
        user: {user, meta: meta},
        media: media,
        reactions: reactions,
        tags: tags,
        related_to: {
          related,
          user: {
            related_user,
            meta: related_user_meta
          },
          media: related_media,
          tags: related_tags,
          reactions: related_reactions
        }
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
    |> Multi.run(:medias, &handle_medias(&1.post, attrs))
    |> Multi.run(:post_replies, &update_parent_post_replies(&1.post, attrs))
    |> Multi.run(:related_to, &handle_related_to(&1.post, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{post: post} = _results} ->
        {:ok, post |> Repo.preload(:media) |> Repo.preload(:related_to)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}

      error ->
        error
    end
  end

  defp update_parent_post_replies(post, _attrs) do
    if(post.nesting_level > 0) do
      {count, _} =
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [replies_count: 1]]
        )
        |> Repo.update_all([])

      if(count == 1) do
        {:ok, nil}
      else
        {:error, "there was an error trying to update parent post replies count"}
      end
    else
      {:ok, nil}
    end
  end

  defp handle_related_to(post, _attrs) do
    if(is_nil(post.related_to_id)) do
      {:ok, nil}
    else
      {count, _} =
        from(
          p in Post,
          where: p.id == ^post.related_to_id and is_nil(p.deleted_at),
          update: [inc: [shares_count: 1]]
        )
        |> Repo.update_all([])

      if(count == 1) do
        {:ok, nil}
      else
        {:error, "there was an error trying to update parent post shares count"}
      end
    end
  end

  defp handle_medias(post, attrs) do
    medias = attrs["medias"]

    if(not is_nil(medias)) do
      if(length(medias) <= @max_media_count) do
        medias = attrs["medias"]

        ids = Enum.map(medias, fn x -> IdHasher.decode(x["id"]) end)

        {_count, medias} =
          from(m in MediaItem, where: m.id in ^ids)
          |> Repo.update_all([set: [temporary: false]], returning: true)

        post
        |> Repo.preload(:media)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:media, medias)
        |> Repo.update()
      else
        {:error, "media count exceeded"}
      end
    else
      {:ok, nil}
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

  def delete_post(%Post{} = post) do
    post
    |> Repo.soft_delete()
  end

  @doc """
  Hard deletes a Post.

  ## Examples

      iex> hard_delete_post(post)
      {:ok, %Post{}}

      iex> hard_delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def hard_delete_post(%Post{} = post) do
    if post.nesting_level > 0 do
      # Update parent post replies count
      from(
        p in Post,
        where: p.id == ^post.parent_id,
        update: [inc: [replies_count: -1]]
      )
      |> Repo.update_all([])
    end

    if(not is_nil(post.related_to_id)) do
      from(
        p in Post,
        where: p.id == ^post.parent_id,
        update: [inc: [shares_count: -1]]
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
      as: :post,
      where: is_nil(post.deleted_at),
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      left_join: media in assoc(post, :media),
      left_join: reactions in assoc(post, :reactions),
      left_join: tags in assoc(post, :tags),
      left_join: related in assoc(post, :related_to),
      left_join: related_user in assoc(related, :user),
      left_join: related_user_meta in assoc(related_user, :meta),
      left_join: related_tags in assoc(related, :tags),
      left_join: related_media in assoc(related, :media),
      left_join: related_reactions in assoc(related, :reactions),
      preload: [
        post: {
          post,
          user: {user, meta: meta},
          media: media,
          reactions: reactions,
          tags: tags,
          related_to: {
            related,
            user: {
              related_user,
              meta: related_user_meta
            },
            media: related_media,
            tags: related_tags,
            reactions: related_reactions
          }
        }
      ]
    )
    |> Paginator.paginate(opts)
  end

  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  def get_post_replies(parent_id, opts \\ %{}) do
    Post
    |> where([post], post.parent_id == ^parent_id and is_nil(post.deleted_at))
    |> join(:left, [post], user in assoc(post, :user))
    |> join(:left, [post, user], meta in assoc(user, :meta))
    |> preload(
      [post, user, meta],
      user: {user, meta: meta}
    )
    |> Paginator.paginate(opts)
  end

  def push_acitivity(post, recipients \\ []) do
    activities =
      Enum.map(recipients, fn elem ->
        %{user_id: elem, post_id: post.id}
      end)

    Repo.insert_all(Activity, activities)
  end
end
