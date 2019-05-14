defmodule Embers.Feed do
  @moduledoc """
  El modulo para interactuar con los posts y otras entidades que conforman
  los distintos feeds de Embers.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Embers.Feed.{Activity, Post}
  alias Embers.Helpers.IdHasher
  alias Embers.Media.MediaItem
  alias Embers.Paginator
  alias Embers.Repo
  alias Embers.Tags

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
  Gets a single post with preloaded associations.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    query =
      from(
        post in Post,
        where: post.id == ^id and is_nil(post.deleted_at),
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [:media, :tags, :reactions, related_to: [:media, :tags, :reactions]],
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

    Repo.one(query)
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

    # Inicializar la transaccion
    Multi.new()
    # Intentamos insertar el post
    |> Multi.insert(:post, post_changeset)
    # Si hay medios, asociarlos al post y quitarles el flag de temporal
    |> Multi.run(:medias, fn _repo, %{post: post} -> handle_medias(post, attrs) end)
    # Buscar tags en los atributos y en el cuerpo el post
    |> Multi.run(:tags, fn _repo, %{post: post} -> handle_tags(post, attrs) end)
    # Actualizar el contador de respuestas del post padre
    |> Multi.run(:post_replies, fn _repo, %{post: post} ->
      update_parent_post_replies(post, attrs)
    end)
    # Si el post es compartido, realizar las acciones correspondientes
    # (Como actualizar el contador de compartidos)
    |> Multi.run(:related_to, fn _repo, %{post: post} -> handle_related_to(post, attrs) end)
    # Ejecutar la transaccion
    |> Repo.transaction()
    |> case do
      {:ok, %{post: post} = _results} ->
        # El post se creo exitosamente, asi que levantamos todas las
        # asociaciones que hacen falta para poder mostrarlo en el front
        post =
          post
          |> Repo.preload([[user: :meta], :media, :tags, [related_to: [:media, user: :meta]]])

        # Disparamos un evento
        Embers.Event.emit(:post_created, post)

        {:ok, post}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
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

  defp handle_medias(post, attrs) do
    medias = attrs["medias"]

    if is_nil(medias) do
      {:ok, nil}
    else
      if length(medias) <= @max_media_count do
        medias = attrs["medias"]

        ids = Enum.map(medias, fn x -> IdHasher.decode(x["id"]) end)

        {_count, medias} =
          Repo.update_all(
            from(m in MediaItem, where: m.id in ^ids),
            [set: [temporary: false]],
            returning: true
          )

        post
        |> Repo.preload(:media)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:media, medias)
        |> Repo.update()
      else
        {:error, "media count exceeded"}
      end
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

  def get_public(opts \\ []) do
    query =
      from(
        post in Post,
        where: post.nesting_level == 0 and is_nil(post.deleted_at),
        where: is_nil(post.related_to_id),
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        preload: [:media, :reactions],
        preload: [
          user: {user, meta: meta}
        ]
      )

    Paginator.paginate(query, opts)
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
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [
          [post: [:media, :reactions, :tags, related_to: [:media, :tags, :reactions]]]
        ],
        preload: [
          post: {
            post,
            user: {user, meta: meta},
            related_to: {
              related,
              user: {
                related_user,
                meta: related_user_meta
              }
            }
          }
        ]
      )

    query
    |> Paginator.paginate(opts)
    |> activities_to_posts
  end

  def get_user_activities(user_id, opts \\ []) do
    query =
      from(
        post in Post,
        where: post.user_id == ^user_id,
        where: is_nil(post.deleted_at),
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        left_join: related in assoc(post, :related_to),
        left_join: related_user in assoc(related, :user),
        left_join: related_user_meta in assoc(related_user, :meta),
        preload: [
          [:media, :reactions, :tags, related_to: [:media, :tags, :reactions]]
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

    Paginator.paginate(query, opts)
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
            [:media, :reactions, :tags]
          ],
          preload: [
            user: {user, meta: meta}
          ],
          limit: ^limit
        )

      Map.put(acc, tag, Repo.all(query))
    end)
  end

  def delete_activity(%Activity{} = activity) do
    with {:ok, activity} <- Repo.delete(activity) do
      Embers.Event.emit(:activity_deleted, activity)
    else
      error -> error
    end
  end

  @doc """
  Devuelve las respuestas a un post.
  """
  def get_post_replies(parent_id, opts \\ []) do
    query =
      from(
        post in Post,
        where: post.parent_id == ^parent_id and is_nil(post.deleted_at),
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        order_by: [desc: post.inserted_at],
        preload: [user: {user, meta: meta}],
        preload: [:reactions, :media]
      )

    Paginator.paginate(query, opts)
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

  defp handle_tags(post, attrs) do
    hashtag_regex = ~r/(?<!\w)#\w+/

    # Buscar tags en el cuerpo del post
    hashtags =
      if is_nil(post.body) do
        []
      else
        hashtag_regex
        |> Regex.scan(post.body)
        |> Enum.map(fn [txt] -> String.replace(txt, "#", "") end)
      end

    # Sumarle los tags enviados en el campo "tags"
    hashtags =
      if Map.has_key?(attrs, "tags") and is_list(attrs["tags"]) do
        Enum.concat(hashtags, attrs["tags"])
      else
        hashtags
      end

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

    # Devolver un tuple con {:ok, _algo} porque esta accion se realiza
    # dentro de una transaccion.
    # Se podria hacer que falle toda la operacion si no se pudo insertar
    # un tag.
    {:ok, nil}
  end

  defp current_date_naive do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  defp activities_to_posts(page) do
    %{page | entries: Enum.map(page.entries, fn a -> a.post end)}
  end
end
