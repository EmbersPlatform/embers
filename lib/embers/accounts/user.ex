defmodule Embers.Accounts.User do
  @moduledoc """
  El esquema de los usuarios.

  ## Campos
  - `:username` - Es el nombre del usuario. Puede tener entre 2 y 30 letras,
    números, - y _.
  - `:canonical` - Igual que `:username`, pero todas las letras son minúsculas.
    Es preferible utilizar siempre este campo para buscar usuarios.
  - `:email` - El email del usuario.
  - `:password` - Es el campo que se recibe al crear el usuario, en texto
    plano. Es un campo virtual: no se persiste en la db.
  - `:password_hash` - Es el hash de la contraseña, que sí es almacenado en la
    db. El algoritmo usado es `Pbkdf2` con `sha-256`.
  - `:confirmed_at` - La fecha en que se confirmó la cuenta. Si este campo es
    `nil`, el usuario no podrá iniciar sesión hasta que confirme su cuenta.
  - `:reset_sent_at` - La fecha en que se envió el último mail para restablecer
    la contraseña.

  ## Asociaciones

  - `:sessions`: Son las sesiones abiertas por el usuario. Hay más información sobre las
  sesiones en el módulo `Embers.Sessions`

  - `:meta`: Es la información adicional del usuario, como la descripción de su perfil,
  o su avatar y portada.

  - `:settings`: Es la configuración del usuario.

  - `:posts`: Los posts creados por el usuario.

  ## Campos virtuales

  - `:following`: Usado para saber si el usuario actualmente autenticado está
  siguiendo al usuario en cuestión.
  - `:blocked`: Similar a `:following`, pero para saber si el usuario fue bloqueado.
  - `:stats`: Usado para mostrar estadisticas del usuario, como la cantidad de
  seguidores o de posts creados.
  """
  use Ecto.Schema

  use Pow.Ecto.Schema,
    password_hash_methods: {&Pbkdf2.add_hash/1, &Pbkdf2.verify_pass/2}

  import Ecto.Changeset
  import Ecto.Query

  alias Embers.Accounts.User

  @type t() :: %__MODULE__{}

  schema "users" do
    field(:username, :string)
    field(:canonical, :string)
    field(:confirmed_at, :utc_datetime)
    field(:reset_sent_at, :utc_datetime)
    field(:banned_at, :utc_datetime)

    field(:following, :boolean, virtual: true, default: false)
    field(:follows_me, :boolean, virtual: true, default: false)
    field(:blocked, :boolean, virtual: true)
    field(:stats, :map, virtual: true, default: false)

    has_one(:meta, Embers.Profile.Meta)
    has_one(:settings, Embers.Profile.Settings.Setting)
    has_many(:posts, Embers.Posts.Post)

    has_many(:bans, Embers.Moderation.Ban)

    many_to_many(:roles, Embers.Authorization.Role, join_through: "role_user")

    pow_user_fields()

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> unique_email
    |> validate_username
    |> cast_assoc(:meta)
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_confirmation(:password)
    |> validate_username
    |> unique_email
    |> validate_password(:password)
    |> put_pass_hash
    |> put_canonical_username
  end

  def create_changeset_raw(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :id])
    |> validate_required([:username, :email, :password_hash, :id])
    |> unique_email
    |> put_canonical_username
  end

  def confirm_changeset(user) do
    change(user, %{confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  def password_reset_changeset(user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  def load_following_status(%User{} = user, follower_id) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^follower_id)
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    %{user | following: count > 0}
  end

  def load_follows_me_status(%User{} = user, follower_id) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.source_id == ^follower_id)
      |> where([s], s.user_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    %{user | follows_me: count > 0}
  end

  def load_blocked_status(%User{} = user, follower_id) do
    count =
      Embers.Blocks.UserBlock
      |> where([b], b.user_id == ^follower_id)
      |> where([b], b.source_id == ^user.id)
      |> select([b], count(b.id))
      |> Embers.Repo.one()

    %{user | blocked: count > 0}
  end

  def populate(%User{} = user) do
    user
    |> load_stats_map
  end

  def populate(nil), do: nil

  def load_stats_map(%User{} = user) do
    stats = %{
      followers: get_followers_count(user),
      friends: get_friends_count(user),
      posts: get_posts_count(user),
      comments: get_comments_count(user)
    }

    %{user | stats: stats}
  end

  def get_followers_count(%User{} = user) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  def get_friends_count(%User{} = user) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  def get_posts_count(%User{} = user) do
    from(p in Embers.Posts.Post,
      where: p.user_id == ^user.id,
      where: is_nil(p.deleted_at),
      where: p.nesting_level == 0,
      select: count(p.id)
    )
    |> Embers.Repo.one()
  end

  def get_comments_count(%User{} = user) do
    from(p in Embers.Posts.Post,
      where: p.user_id == ^user.id,
      where: is_nil(p.deleted_at),
      where: p.nesting_level > 0,
      select: count(p.id)
    )
    |> Embers.Repo.one()
  end

  defp unique_email(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_format(:username, ~r/^([A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*)$/)
    |> validate_length(:username, max: 30, min: 2)
    |> unique_constraint(:username)
  end

  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Argon2 or Pbkdf2, change Bcrypt to Argon2 or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  defp strong_password?(password) when byte_size(password) > 7 do
    NotQwerty123.PasswordStrength.strong_password?(password)
  end

  defp strong_password?(_), do: {:error, "The password is too short"}

  # Inserts a lowercase version of the username in the canonical column
  # Canonical purpose is to make faster and case insensitive username searchs
  defp put_canonical_username(
         %Ecto.Changeset{valid?: true, changes: %{username: username}} = changeset
       ) do
    change(changeset, canonical: String.downcase(username))
  end

  defp put_canonical_username(changeset), do: changeset
end

defimpl FunWithFlags.Actor, for: Embers.Accounts.User do
  def id(%{id: id}) do
    "user:#{id}"
  end
end
