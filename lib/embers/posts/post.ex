defmodule Embers.Posts.Post do
  @moduledoc """
  Un post es la unidad mínima de contenido en Embers. Consiste de un
  cuerpo de texto que no exceda los 1600 caracteres, y opcionalmente
  hasta 4 medios asociados(imagen, video, etc).

  De los posts se derivan los comentarios, respuestas, compartidos, que son
  posts a los que se les da un distinto significado basandose en campos como
  `:nesting_level`/`:parent_id` y `:related_to_id`.

  ## Nivel de anidamiento
  El `nesting_level` o nivel de anidamiento, representa qué tan profundo se
  encuentra el post en la cadena de posts. De acuerdo a este nivel, se
  considera a un post como:
  - `0` - Post
  - `1` - Comentario
  - `2` - Respuesta (a un Comentario)

  Esto permite reutilizar el post para varios escenarios, evitando la
  duplicación de código en el backend y limitando la superficie expuesta a
  fallos.

  Se eligió limitar el anidamiento para evitar lidiar con interfaces poco
  amigables como es el caso de Reddit y HackerNews. Además hace que los
  posts con un nivel de anidamiento muy alto acaben perdidos o que el se
  vuelvan demasiado off-topic, al punto de ser molestos para el OP.

  ## Compartidos
  A los posts que están relacionados a otros posts se los considera como
  Compartidos.
  Este tipo de post puede tener un cuerpo, pero no puede tener medios
  asociados.

  Para que un post sea un Compartido, debe tener asignado un valor en el campo
  `related_to_id`. Si el post "padre" es eliminado, también son eliminados
  todos los posts compartidos derivados de éste.
  Se diseñó de esta forma para asegurar la integridad de la información usando
  llaves foráneas con eliminación por cascada y evitar la existencia de
  compartidos huérfanos.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Embers.Posts.Post
  alias Embers.Repo

  @max_body_len 1600

  schema "posts" do
    field(:body, :string)
    belongs_to(:user, Embers.Accounts.User)
    field(:nesting_level, :integer, default: 0)
    field(:replies_count, :integer, default: 0)
    field(:shares_count, :integer, default: 0)
    field(:my_reactions, {:array, :string}, virtual: true)
    field(:mentions, {:array, :string}, virtual: true)
    field(:nsfw, :boolean, virtual: true, default: false)
    field(:faved, :boolean, virtual: true, default: false)

    belongs_to(:parent, __MODULE__)
    belongs_to(:related_to, __MODULE__)
    has_many(:replies, __MODULE__)
    has_many(:reactions, Embers.Reactions.Reaction)

    many_to_many(:tags, Embers.Tags.Tag, join_through: "tags_posts")
    many_to_many(:media, Embers.Media.MediaItem, join_through: "posts_medias")
    many_to_many(:links, Embers.Links.Link, join_through: "link_post")
    field(:old_attachment, {:map, :any})

    field(:deleted_at, :naive_datetime)
    timestamps()
  end

  @doc """
  Valida y prepara un `Post` para su persistencia en la base de datos.

  Los siguientes atributos son casteados a sus correspondientes tipos:
  - :body
  - :user_id
  - :parent_id
  - :related_to_id

  Realiza las siguientes validaciones:

  - `:user_id` esta presente
  - El `User` asociado debe existir
  - Si `:parent_id` esta presente, debe existir
  - Si `:related_to_id` esta presente, debe existir
  - Solo pueden proveerse `:parent_id` o `:related_to_id`, no ambos
  - El `:nesting_level` calculado en base al `:parent_id` no es mayor que 2
  - Si se provee una lista de `MediaItem`s, deben ser maximo 4
  - Si se provee una lista de `Link`s, debe ser maximo 1
  - Luego de recortar el cuerpo del post, debe tener maximo 1600 caracteres

  Ademas realiza las siguientes transformaciones:

  - El `:body` es recortado
  - El `:nesting_level` es calculado y asignado
  """
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :parent_id, :related_to_id])
    |> validate_required([:user_id])
    |> assoc_constraint(:user)
    |> validate_only_parent_or_related()
    |> validate_related_to()
    |> validate_parent_and_set_nesting_level()
    |> validate_number(:nesting_level, less_than_or_equal_to: 2)
    |> maybe_put_media
    |> maybe_put_link
    |> trim_body()
    |> validate_body()
    |> maybe_put_tags
    |> check_share_rate_limit()
  end

  @doc """
  Hace lo mismo que `changeset/2`, pero agrega las siguientes acciones que se
  realizaran en la misma transaccion y con el mismo repo que se conecta con la
  base de datos:
  - Si `:parent_id` esta presente y existe, incrementa su `:replies_count` en 1
  - Si `:related_to_id` esta presente y existe, incrementa su `:shares_count`
    en 1
  """
  def create_changeset(post, attrs) do
    post
    |> changeset(attrs)
    |> prepare_changes(fn changeset ->
      repo = changeset.repo

      if parent_id = get_change(changeset, :parent_id) do
        repo.update_all(
          from(
            p in __MODULE__,
            where: p.id == ^parent_id,
            update: [inc: [replies_count: 1]]
          ),
          []
        )
      end

      changeset
    end)
    |> prepare_changes(fn changeset ->
      repo = changeset.repo

      if related_to_id = get_change(changeset, :related_to_id) do
        repo.update_all(
          from(
            p in __MODULE__,
            where: p.id == ^related_to_id,
            update: [inc: [shares_count: 1]]
          ),
          []
        )
      end

      changeset
    end)
  end

  @doc """
  Sets the virtual field `nsfw` to true if loaded tags contain the "nsfw" tag.
  """
  def fill_nsfw(nil), do: nil

  def fill_nsfw(%__MODULE__{} = post) do
    if Ecto.assoc_loaded?(post.tags) do
      post = %{
        post
        | nsfw: Enum.any?(post.tags, fn tag -> String.downcase(tag.name) == "nsfw" end)
      }

      post =
        if Ecto.assoc_loaded?(post.related_to) do
          %{post | related_to: fill_nsfw(post.related_to)}
        end || post

      post
    else
      post
    end
  end

  @doc """
  Given a string, returns a List of valid tags

  ## Examples
      iex>parse_tags("#test")
      ["test]

      iex>parse_tags(#hello #world)
      ["hello", "world"]
  """
  @spec parse_tags(String.t()) :: [String.t()]
  def parse_tags(text) do
    hashtag_regex = ~r/(?<!\w)#\w+/

    if is_nil(text) do
      []
    else
      hashtag_regex
      |> Regex.scan(text)
      |> Enum.map(fn [txt] -> String.replace(txt, "#", "") end)
    end
  end

  defp must_have_body?(changeset) do
    medias = get_change(changeset, :media) || []
    links = get_change(changeset, :links) || []
    related = get_change(changeset, :related_to_id)
    is_shared? = not is_nil(related)
    has_media? = length(medias) > 0
    has_link? = length(links) > 0

    if is_shared? do
      false
    else
      !has_media? && !has_link?
    end
  end

  defp validate_body(changeset) do
    if must_have_body?(changeset) do
      changeset
      |> validate_required([:body])
      |> validate_length(:body, min: 1)
      |> validate_length(:body, max: @max_body_len)
    else
      changeset
    end
  end

  defp trim_body(changeset) do
    body = get_change(changeset, :body)

    unless is_nil(body) do
      changeset
      |> change(body: String.trim(body))
    end || changeset
  end

  defp validate_parent_and_set_nesting_level(changeset) do
    parent_id = get_change(changeset, :parent_id)
    validate_parent_and_set_nesting_level(changeset, parent_id)
  end

  defp validate_parent_and_set_nesting_level(changeset, nil), do: changeset

  defp validate_parent_and_set_nesting_level(changeset, parent_id) do
    case Repo.get(Post, parent_id) do
      nil ->
        changeset
        |> Ecto.Changeset.add_error(:parent, "parent post does not exist")

      parent ->
        changeset
        |> check_if_can_reply(parent)
        |> set_nesting_level(parent.nesting_level)
    end
  end

  defp set_nesting_level(changeset, parent_nesting_level) do
    if parent_nesting_level < 2 do
      changeset
      |> change(nesting_level: parent_nesting_level + 1)
    else
      changeset
      |> add_error(:nesting_level, "max nesting level is 2")
    end
  end

  defp check_if_can_reply(changeset, parent) do
    user_id = get_change(changeset, :user_id)

    parent_owner =
      Embers.Accounts.get_user(parent.user_id)
      |> Repo.preload([:settings])
      |> Embers.Accounts.User.load_follows_me_status(user_id)

    is_blocked? =
      Repo.exists?(
        from(
          b in Embers.Blocks.UserBlock,
          where: b.source_id == ^user_id,
          where: b.user_id == ^parent.user_id
        )
      )

    IO.inspect(parent_owner, label: "OWNER")

    is_trusted? =
      cond do
        parent_owner.settings.privacy_trust_level == "everyone" ->
          true

        parent_owner.settings.privacy_trust_level == "followers" and !parent_owner.follows_me ->
          false

        true ->
          true
      end

    cond do
      is_blocked? ->
        Ecto.Changeset.add_error(
          changeset,
          :blocked,
          "parent post owner has blocked the post creator"
        )

      !is_trusted? ->
        Ecto.Changeset.add_error(changeset, :blocked, "can't comment to this user posts")

      true ->
        changeset
    end
  end

  defp check_share_rate_limit(changeset) do
    related_id = get_change(changeset, :related_to_id)
    user_id = get_change(changeset, :user_id)

    since_date =
      Timex.now()
      |> Timex.shift(minutes: -5)

    case related_id do
      nil ->
        changeset

      _ ->
        recently_shared? =
          Repo.exists?(
            from(
              post in Post,
              where: post.related_to_id == ^related_id,
              where: post.user_id == ^user_id,
              where: post.inserted_at >= ^since_date
            )
          )

        if recently_shared? do
          changeset
          |> add_error(:related_to, "rate limited")
        else
          changeset
        end
    end
  end

  defp validate_only_parent_or_related(changeset) do
    parent_id = get_change(changeset, :parent_id)
    related_to_id = get_change(changeset, :related_to_id)

    if not is_nil(parent_id) and not is_nil(related_to_id) do
      Ecto.Changeset.add_error(
        changeset,
        :invalid_data,
        "only one of `parent_id` and `related_to_id` can be present at the same time"
      )
    else
      changeset
    end
  end

  defp validate_related_to(changeset) do
    if not is_nil(get_change(changeset, :related_to_id)) do
      assoc_constraint(changeset, :related_to)
    else
      changeset
    end
  end

  defp maybe_put_media(%{params: %{"media" => media}} = changeset)
       when not is_nil(media) do
    changeset
    |> put_assoc(:media, media)
    |> validate_length(:media, max: 4)
  end

  defp maybe_put_media(changeset), do: changeset

  defp maybe_put_link(%{params: %{"links" => links}} = changeset)
       when not is_nil(links) do
    changeset
    |> put_assoc(:links, links)
    |> validate_length(:links, max: 1)
  end

  defp maybe_put_link(changeset), do: changeset

  defp maybe_put_tags(%{params: %{"tags" => tags}} = changeset) do
    tags = Enum.filter(tags, fn tag -> match?(%Embers.Tags.Tag{}, tag) end)

    changeset
    |> put_assoc(:tags, tags)
    |> validate_length(:tags, max: 10)
  end

  defp maybe_put_tags(changeset), do: changeset
end
