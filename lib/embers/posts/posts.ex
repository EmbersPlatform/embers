defmodule Embers.Posts do
  import Ecto.Query

  alias Embers.Helpers.IdHasher
  alias Embers.Links.Link
  alias Embers.Paginator
  alias Embers.Posts.Post
  alias Embers.Repo
  alias Embers.Tags

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
        where: post.id == ^id and is_nil(post.deleted_at),
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [:media, :links, :tags, :reactions, related_to: [:media, :tags, :reactions]],
        # Acá precargamos todo lo que levantamos más arriba con los joins,
        # de lo contrario Ecto no mapeará los resultados a los esquemas
        # correspondientes.
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
      nil -> {:error, :not_found}
      post -> {:ok, post |> Post.fill_nsfw()}
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
    post_changeset = Post.changeset(%Post{}, attrs)

    with {:ok, post} <- Repo.insert(post_changeset) do
      {:ok, post} = get_post(post.id)
      emit_event? = Keyword.get(opts, :emit_event?, true)
      if emit_event? do
        Embers.Event.emit(:post_created, post)
      end
      {:ok, post}
    end
  end

  defp update_parent_post_replies(post, _attrs) do
    if post.nesting_level > 0 do
      {_, [parent]} =
        Repo.update_all(
          from(
            p in Post,
            where: p.id == ^post.parent_id,
            update: [inc: [replies_count: 1]]
          ),
          [],
          returning: true
        )

      Embers.Event.emit(:post_comment, %{
        from: post.user_id,
        recipient: parent.user_id,
        source: parent.id
      })
    end

    {:ok, nil}
  end

  defp handle_related_to(post, _attrs) do
    if not is_nil(post.related_to_id) do
      {_, [parent]} =
        Repo.update_all(
          from(
            p in Post,
            where: p.id == ^post.related_to_id,
            where: is_nil(p.deleted_at),
            update: [inc: [shares_count: 1]]
          ),
          [],
          returning: true
        )

      Embers.Event.emit(:post_shared, %{
        from: post.user_id,
        recipient: parent.user_id,
        source: post.id
      })
    end

    {:ok, nil}
  end

  defp handle_links(post, attrs) do
    links = attrs["links"]

    if is_nil(links) do
      {:ok, nil}
    else
      ids = Enum.map(links, fn x -> IdHasher.decode(x["id"]) end)

      {_count, links} =
        Repo.update_all(
          from(l in Link, where: l.id in ^ids),
          [set: [temporary: false]],
          returning: true
        )

      post
      |> Repo.preload(:links)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:links, links)
      |> Repo.update()
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

  defp handle_tags(post, attrs) do
    IO.inspect("HANDLING TAGS")
    hashtags = Post.parse_tags(post.body)

    # Sumarle los tags enviados en el campo "tags"
    hashtags =
      if Map.has_key?(attrs, "tags") and is_list(attrs["tags"]) do
        Enum.concat(hashtags, attrs["tags"])
      else
        hashtags
      end

    hashtags = Enum.filter(hashtags, fn name -> Tags.Tag.valid_name?(name) end)

    IO.inspect(hashtags, label: "LOS TAGS AAAAAAAAAAAAAAAAAAAAAA")

    # Crear los tags que hacaen falta y obtener los ids que hacen falta
    tags_ids = Tags.bulk_create_tags(hashtags)

    # Generar una lista de los datos a insertar en la tabla "tag_post"
    tag_post_list =
      Enum.map(tags_ids, fn tag_id ->
        %{
          post_id: post.id,
          tag_id: tag_id,
          inserted_at: current_date_naive(),
          updated_at: current_date_naive()
        }
      end)

    Embers.Repo.insert_all(Embers.Tags.TagPost, tag_post_list)

    {:ok, nil}
  end

  defp current_date_naive do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end
end
