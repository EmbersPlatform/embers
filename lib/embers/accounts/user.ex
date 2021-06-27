defmodule Embers.Accounts.User do
  @moduledoc """
  The users schema

  ## fields
  - `:username` - The user's display name. It's between 2 and 30 characters of
  length and allows letters, numbers, - and _.
  - `:canonical` - Lowercase version of the username for case insensitive lookup
  and mentions. In the future this will be used as the user's handle.
  - `:email` - The user's email
  - `:password` - A virtual field for use when registering the user.
  - `:password_hash` - The password hash.
  - `:confirmed_at` - The date the account was confirmed

  ## Associations

  - `:meta`: The user's profile data

  - `:settings`: The user settings

  - `:posts`: The posts created by the user

  ## Virtual field

  - `:following`: A boolean representing if the user is being followed by the
  current user
  - `:blocked`: Like  `:following`, but for blocks
  - `:stats`: Use to show user stats such as posts or followers count
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :naive_datetime)

    field(:username, :string)
    field(:canonical, :string)
    field(:banned_at, :utc_datetime)

    field(:following, :boolean, virtual: true, default: false)
    field(:follows_me, :boolean, virtual: true, default: false)
    field(:blocked, :boolean, virtual: true)
    field(:stats, :map, virtual: true)

    has_one(:meta, Embers.Profile.Meta)
    has_one(:settings, Embers.Profile.Settings.Setting)
    has_many(:posts, Embers.Posts.Post)

    has_many(:bans, Embers.Moderation.Ban)

    many_to_many(:roles, Embers.Authorization.Role, join_through: "role_user")
    field(:permissions, {:array, :string}, virtual: true)

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_email()
    |> validate_password(opts)
    |> validate_username()
    |> put_canonical_username()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Embers.Repo)
    |> unique_constraint(:email)
    |> validate_non_temporary_email()
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

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_format(:username, ~r/^([A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*)$/)
    |> validate_length(:username, max: 30, min: 2)
    |> unique_constraint(:username)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 80)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
    |> validate_change(:password, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{:password, opts[:message] || msg}]
      end
    end)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Pbkdf2.no_user_verify/0` to avoid timing attacks.
  """
  @spec valid_password?(User.t(), String.t()) :: boolean
  def valid_password?(%Embers.Accounts.User{password_hash: password_hash}, password)
      when is_binary(password_hash) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, password_hash)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  @spec validate_current_password(Ecto.Changeset.t(), String.t()) :: Ecto.Changeset.t()
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

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
      query = from(u in __MODULE__, where: u.canonical == ^canonical)

      case changeset.repo.exists?(query) do
        false -> changeset
        true -> add_error(changeset, :username, "has already been taken")
      end
    end)
  end

  @doc """
  Returns a query to retrieve users and preload their `meta`
  """
  @spec user_with_profile_query() :: Ecto.Query.t()
  def user_with_profile_query() do
    from(user in __MODULE__,
      join: meta in assoc(user, :meta),
      preload: [
        meta: meta
      ]
    )
  end
end
