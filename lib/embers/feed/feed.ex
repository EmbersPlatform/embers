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
  alias Embers.Tags

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
          tags: related_tags
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
    |> Multi.run(:medias, fn _repo, %{post: post} -> handle_medias(post, attrs) end)
    |> Multi.run(:tags, fn _repo, %{post: post} -> handle_tags(post, attrs) end)
    |> Multi.run(:post_replies, fn _repo, %{post: post} ->
      update_parent_post_replies(post, attrs)
    end)
    |> Multi.run(:related_to, fn _repo, %{post: post} -> handle_related_to(post, attrs) end)
    |> Repo.transaction()
    |> case do
      {:ok, %{post: post} = _results} ->
        post =
          post
          |> Repo.preload([[user: :meta], :media, :tags, [related_to: [:media, user: :meta]]])

        Embers.Event.emit(:post_created, post)

        {:ok, post}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}

      error ->
        error
    end
  end

  defp update_parent_post_replies(post, _attrs) do
    if(post.nesting_level > 0) do
      {_, [parent]} =
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [replies_count: 1]]
        )
        |> Repo.update_all([], returning: true)

      Embers.Event.emit(:post_comment, %{
        from: post.user_id,
        recipient: parent.user_id,
        source: parent.id
      })

      {:ok, nil}
    else
      {:ok, nil}
    end
  end

  defp handle_related_to(post, _attrs) do
    if(is_nil(post.related_to_id)) do
      {:ok, nil}
    else
      post.related_to_id |> IO.inspect()

      {_, [parent]} =
        from(
          p in Post,
          where: p.id == ^post.related_to_id,
          where: is_nil(p.deleted_at),
          update: [inc: [shares_count: 1]]
        )
        |> Repo.update_all([], returning: true)

      Embers.Event.emit(:post_shared, %{
        from: post.user_id,
        recipient: parent.user_id,
        source: post.id
      })

      {:ok, nil}
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
    with {:ok, post} <- Repo.soft_delete(post) do
      Embers.Event.emit(:post_deleted, post)
      {:ok, post}
    else
      error -> error
    end
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

    with {:ok, deleted_post} <- Repo.delete(post) do
      Embers.Event.emit(:post_deleted, deleted_post)
      {:ok, deleted_post}
    else
      error -> error
    end
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

  def get_timeline(user_id, opts \\ []) do
    from(
      activity in Activity,
      where: activity.user_id == ^user_id,
      left_join: post in assoc(activity, :post),
      where: is_nil(post.deleted_at),
      order_by: [desc: activity.id],
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
    with {:ok, activity} <- Repo.delete(activity) do
      Embers.Event.emit(:activity_deleted, activity)
    else
      error -> error
    end
  end

  def get_post_replies(parent_id, opts \\ %{}) do
    from(
      post in Post,
      where: post.parent_id == ^parent_id and is_nil(post.deleted_at),
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      order_by: [asc: post.inserted_at],
      preload: [user: {user, meta: meta}]
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

  defp handle_tags(post, attrs) do
    hashtag_regex = ~r/(?<!\w)#\w+/

    hashtags =
      if is_nil(post.body) do
        []
      else
        Regex.scan(hashtag_regex, post.body)
        |> Enum.map(fn [txt] -> String.replace(txt, "#", "") end)
      end

    hashtags =
      if Map.has_key?(attrs, "tags") and is_list(attrs["tags"]) do
        Enum.concat(hashtags, attrs["tags"])
      else
        hashtags
      end

    tags_ids = Tags.bulk_create_tags(hashtags)

    tag_post_list =
      Enum.map(tags_ids, fn tag_id ->
        %{
          post_id: post.id,
          tag_id: tag_id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Embers.Repo.insert_all(Embers.Tags.TagPost, tag_post_list)
    {:ok, nil}
  end
end
