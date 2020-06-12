defmodule Embers.Posts do
  import Ecto.Query

  alias Embers.Paginator
  alias Embers.Posts.Post
  alias Embers.Repo

  @doc """
  Returns the list of *all* the posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post with preloaded associations.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post(nil), do: {:error, :not_found}

  def get_post(id) do
    query =
      from(
        post in Post,
        where: post.id == ^id,
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [
          :media,
          :links,
          :tags,
          :reactions,
          related_to: [:media, :links, :tags, :reactions]
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

    res = Repo.one(query)

    case res do
      nil ->
        {:error, :not_found}

      %{deleted_at: deleted_at} when not is_nil(deleted_at) ->
        {:error, :post_disabled}

      post ->
        {:ok, post |> Post.fill_nsfw()}
    end
  end

  def get_post!(nil), do: nil

  def get_post!(id) do
    case get_post(id) do
      {:error, _reason} -> nil
      {:ok, post} -> post
    end
  end

  @doc """
  Creates a post. See `Embers.Posts.Post.changeset/2` for validations.
  """
  def create_post(attrs, opts \\ []) do
    post_changeset = Post.create_changeset(%Post{}, attrs)

    with {:ok, post} <- Repo.insert(post_changeset) do
      {:ok, post} = get_post(post.id)
      emit_event? = Keyword.get(opts, :emit_event?, true)

      if emit_event? do
        Embers.Event.emit(:post_created, post)
      end

      {:ok, post}
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

  def delete_post(%Post{} = post, actor \\ nil) do
    if post.nesting_level > 0 do
      # Update parent post replies count
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [replies_count: -1]]
        ),
        []
      )
    end

    unless is_nil(post.related_to_id) do
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.related_to_id,
          update: [inc: [shares_count: -1]]
        ),
        []
      )
    end

    with {:ok, post} <- Repo.soft_delete(post) do
      Embers.Event.emit(:post_disabled, %{post: post, actor: actor})
      {:ok, post}
    else
      error -> error
    end
  end

  def restore_post(%Post{} = post, actor \\ nil) do
    if post.nesting_level > 0 do
      # Update parent post replies count
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [replies_count: 1]]
        ),
        []
      )
    end

    unless is_nil(post.related_to_id) do
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [shares_count: 1]]
        ),
        []
      )
    end

    with {:ok, post} <- Repo.restore_entry(post) do
      Embers.Event.emit(:post_restored, %{post: post, actor: actor})
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
  def hard_delete_post(%Post{} = post, actor \\ nil) do
    if post.nesting_level > 0 do
      # Update parent post replies count
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [replies_count: -1]]
        ),
        []
      )
    end

    unless is_nil(post.related_to_id) do
      Repo.update_all(
        from(
          p in Post,
          where: p.id == ^post.parent_id,
          update: [inc: [shares_count: -1]]
        ),
        []
      )
    end

    with {:ok, deleted_post} <- Repo.delete(post) do
      Embers.Event.emit(:post_deleted, %{post: deleted_post, actor: actor})
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

  @doc """
  Devuelve las respuestas a un post.
  """
  def get_post_replies(parent_id, opts \\ []) do
    order = Keyword.get(opts, :order, :asc)

    query =
      from(
        post in Post,
        where: post.parent_id == ^parent_id and is_nil(post.deleted_at),
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        preload: [user: {user, meta: meta}],
        preload: [:reactions, :media, :links, :tags]
      )

    query =
      case order do
        :desc -> from(post in query, order_by: [desc: post.inserted_at])
        :asc -> from(post in query, order_by: [asc: post.inserted_at])
      end

    query
    |> Paginator.paginate(opts)
    |> fill_nsfw()
  end

  defp fill_nsfw(page) do
    %{
      page
      | entries: Enum.map(page.entries, fn post -> Post.fill_nsfw(post) end)
    }
  end

  def bulk_delete_after_date(user_id, after_days \\ 0) do
    after_date =
      Timex.now()
      |> Timex.shift(days: -after_days)

    query = from(
      post in Post,
      where: post.user_id == ^user_id
    )

    query = if after_days == -1 do
      query
    else
      from(post in query, where: post.inserted_at >= ^after_date)
    end

    Repo.delete_all(query)
  end
end
