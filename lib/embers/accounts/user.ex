defmodule Embers.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Embers.Accounts.User

  schema "users" do
    field(:username, :string)
    field(:canonical, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime)
    field(:reset_sent_at, :utc_datetime)
    field(:sessions, {:map, :integer}, default: %{})

    has_one(:meta, Embers.Profile.Meta)
    has_one(:settings, Embers.Profile.Settings.Setting)
    has_many(:posts, Embers.Feed.Post)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_email
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

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> validate_length(:username, min: 2)
    |> unique_constraint(:email)
  end

  defp validate_username(changeset) do
    validate_format(changeset, :username, ~r/^([A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*)$/)
    |> validate_length(:username, max: 20, min: 2)
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
    change(changeset, Comeonin.Pbkdf2.add_hash(password))
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
