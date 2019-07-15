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
    field(:nesting_level, :integer, default: 0)
    field(:replies_count, :integer, default: 0)
    field(:shares_count, :integer, default: 0)
    field(:my_reactions, {:array, :string}, virtual: true)
    field(:mentions, {:array, :string}, virtual: true)
    field(:nsfw, :boolean, virtual: true, default: false)
    field(:faved, :boolean, virtual: true, default: false)

    belongs_to(:user, Embers.Accounts.User)

    # A post may be in reply to another post
    # Comments no longer have their own entity as they had in fenix
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

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :parent_id, :related_to_id])
    |> validate_required([:user_id])
    |> trim_body(attrs)
    |> validate_body(attrs)
    |> validate_related_to(attrs)
    |> validate_parent_and_set_nesting_level(attrs)
    |> validate_number(:nesting_level, less_than_or_equal_to: 2)
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

  defp must_have_body?(attrs) do
    is_shared? = not is_nil(attrs["related_to_id"])
    has_media? = Map.get(attrs, "media_count", 0) > 0
    has_link? = Map.get(attrs, "links_count", 0) > 0

    if is_shared? do
      false
    else
      !has_media? && !has_link?
    end
  end

  defp validate_body(changeset, attrs) do
    if must_have_body?(attrs) do
      changeset
      |> validate_required([:body])
      |> validate_length(:body, min: 1)
      |> validate_length(:body, max: @max_body_len)
    else
      changeset
    end
  end

  defp trim_body(changeset, %{"body" => body} = _attrs) when not is_nil(body) do
    changeset
    |> change(body: String.trim(body))
  end

  defp trim_body(changeset, _), do: changeset

  defp validate_parent_and_set_nesting_level(changeset, %{"parent_id" => parent_id}) do
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

  defp validate_parent_and_set_nesting_level(changeset, _) do
    changeset
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

    is_blocked? =
      Repo.exists?(
        from(
          b in Embers.Blocks.UserBlock,
          where: b.source_id == ^user_id,
          where: b.user_id == ^parent.user_id
        )
      )

    if is_blocked? do
      changeset
      |> Ecto.Changeset.add_error(:blocked, "parent post owner has blocked the post creator")
    else
      changeset
    end
  end

  defp validate_related_to(changeset, attrs) do
    parent_id = attrs["parent_id"]
    related_to_id = attrs["related_to_id"]

    changeset =
      if not is_nil(parent_id) and not is_nil(related_to_id) do
        Ecto.Changeset.add_error(
          changeset,
          :invalid_data,
          "only one of `parent_id` and `related_to` can be present at the same time"
        )
      else
        changeset
      end

    assoc_constraint(changeset, :related_to)
  end
end
