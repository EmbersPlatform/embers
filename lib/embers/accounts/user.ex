defmodule Embers.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Embers.Accounts.User
  alias Embers.Sessions.Session

  schema "users" do
    field(:username, :string)
    field(:canonical, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime)
    field(:reset_sent_at, :utc_datetime)
    has_many(:sessions, Session, on_delete: :delete_all)

    field(:following, :boolean, virtual: true)
    field(:blocked, :boolean, virtual: true)
    field(:stats, :map, virtual: true, default: false)

    has_one(:meta, Embers.Profile.Meta)
    has_one(:settings, Embers.Profile.Settings.Setting)
    has_many(:posts, Embers.Feed.Post)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> unique_email
    |> validate_username
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
      Embers.Feed.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^follower_id)
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    %{user | following: count > 0}
  end

  def load_blocked_status(%User{} = user, follower_id) do
    count =
      Embers.Feed.Subscriptions.UserBlock
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

  def load_stats_map(%User{} = user) do
    stats = %{
      followers: get_followers_count(user),
      friends: get_followers_count(user),
      posts: get_posts_count(user)
    }

    %{user | stats: stats}
  end

  def get_followers_count(%User{} = user) do
    count =
      Embers.Feed.Subscriptions.UserSubscription
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  def get_friends_count(%User{} = user) do
    count =
      Embers.Feed.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  def get_posts_count(%User{} = user) do
    Embers.Feed.Post
    |> where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Embers.Repo.one()
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  defp validate_username(changeset) do
    validate_format(changeset, :username, ~r/^([A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*)$/)
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
