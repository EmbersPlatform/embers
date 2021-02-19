defmodule Embers.Accounts.User.Old do
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

  @moduledoc deprecated: "Use `Embers.Accounts.User` instead"

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Embers.Accounts.User
  alias Embers.Sessions.Session

  @type t() :: %__MODULE__{}

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "users" do
    field(:username, :string)
    field(:canonical, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime)
    field(:reset_sent_at, :utc_datetime)
    field(:banned_at, :utc_datetime)
    has_many(:sessions, Session, on_delete: :delete_all)

    field(:following, :boolean, virtual: true, default: false)
    field(:follows_me, :boolean, virtual: true, default: false)
    field(:blocked, :boolean, virtual: true)
    field(:stats, :map, virtual: true, default: false)

    has_one(:meta, Embers.Profile.Meta)
    has_one(:settings, Embers.Profile.Settings.Setting)
    has_many(:posts, Embers.Posts.Post)

    has_many(:bans, Embers.Moderation.Ban)

    many_to_many(:roles, Embers.Authorization.Role, join_through: "role_user")
    field(:permissions, {:array, :string}, virtual: true)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> validate_non_temporary_email()
    |> validate_unique_email()
    |> validate_username()
    |> cast_assoc(:meta)
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_confirmation(:password)
    |> validate_username()
    |> validate_non_temporary_email()
    |> validate_unique_email()
    |> validate_password(:password)
    |> put_pass_hash()
    |> put_canonical_username()
  end

  @doc """
  Used when batch importing users
  """
  @deprecated "Batch user import should not be needed anymore"
  def create_changeset_raw(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :id])
    |> validate_required([:username, :email, :password_hash, :id])
    |> validate_unique_email()
    |> put_canonical_username()
  end

  @doc """
    Sets the `confirmed_at` field to the current date
  """
  def confirm_changeset(user) do
    confirmation_date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    change(user, %{confirmed_at: confirmation_date})
  end

  @doc """
    Sets the `reset_sent_at` field to the provided date
  """
  def password_reset_changeset(user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  defp validate_non_temporary_email(%{valid?: false} = changeset), do: changeset

  defp validate_non_temporary_email(changeset) do
    email = get_change(changeset, :email)

    if is_nil(email) do
      changeset
    else
      case Embers.Accounts.DisposableEmail.disposable?(email) do
        false -> changeset
        true -> add_error(changeset, :email, "forbidden provider")
      end
    end
  end

  defp validate_unique_email(changeset) do
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
    |> unique_canonical()
  end

  defp put_canonical_username(changeset), do: changeset

  defp unique_canonical(changeset) do
    changeset
    |> prepare_changes(fn changeset ->
      canonical = get_change(changeset, :canonical)
      query = from(u in User, where: u.canonical == ^canonical)

      case changeset.repo.exists?(query) do
        false -> changeset
        true -> add_error(changeset, :username, "has already been taken")
      end
    end)
  end
end
