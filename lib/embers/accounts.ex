defmodule Embers.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Embers.Repo
  alias Embers.Accounts.{User, UserToken, UserNotifier}
  alias Embers.Profile.{Meta, Settings.Setting}
  alias Embers.Authorization.Roles

  @topic inspect(__MODULE__)

  def subscribe_to_events() do
    Phoenix.PubSub.subscribe(Embers.PubSub, @topic)
  end

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    query = User.user_with_profile_query()

    Repo.get_by(query, email: email)
    |> Embers.Profile.load_profile_for_user()
    |> load_stats_map()
  end

  def get_user_by_username(username) when is_binary(username) do
    query = User.user_with_profile_query()

    Repo.get_by(query, canonical: username)
    |> Embers.Profile.load_profile_for_user()
    |> load_stats_map()
  end

  def get_user_by_id(id) do
    query = User.user_with_profile_query()

    Repo.get_by(query, id: id)
    |> Embers.Profile.load_profile_for_user()
    |> load_stats_map()
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_user_by_email_and_password(String.t(), String.t()) :: map | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    query = User.user_with_profile_query()
    user = Repo.get_by(query, email: email) |> load_stats_map()
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a user by username and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

      iex> get_user_by_username_or_email_and_password("john", "correct_password")
      %User{}

      iex> get_user_by_username_or_email_and_password("john", "invalid_password")
      nil

  """
  @spec get_user_by_username_or_email_and_password(String.t(), String.t()) :: map | nil
  def get_user_by_username_or_email_and_password(identifier, password)
      when is_binary(identifier) and is_binary(password) do
    query = User.user_with_profile_query()

    where_opts =
      case Regex.match?(~r/@/, identifier) do
        true -> [email: identifier]
        false -> [canonical: identifier]
      end

    user = Repo.get_by(query, where_opts) |> load_stats_map()
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Returns a page with the existing users

  ## Example
      iex> list_users()
      %Page{
        entries: [%User{}, ...],
        last_page: false,
        next: "next cursor"
      }

  ## Options
  - `:name`: If present, users will be filtered by their `canonical` field
  value

  See `Embers.Paginator.paginate/2` for more options.
  """
  @spec list_users(keyword()) :: Embers.Paginator.Page.t()
  def list_users(opts) do
    order = Keyword.get(opts, :order, :asc)
    filters = Keyword.get(opts, :filters, [])
    preloads = Keyword.get(opts, :preloads, [])

    query =
      from(
        users in User,
        order_by: [{^order, users.inserted_at}],
        preload: ^([:meta] ++ preloads)
      )
      |> maybe_filter_by_name_query(opts)
      |> maybe_apply_filters(filters)
      |> maybe_preload_query(opts)

    Embers.Paginator.paginate(query, opts)
    |> Embers.Paginator.map(fn user ->
      user
      |> Map.update!(:meta, &Embers.Profile.Meta.load_avatar_map/1)
      |> Map.update!(:meta, &Embers.Profile.Meta.load_cover/1)
    end)
  end

  defp maybe_apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {field, value}, q ->
      from(users in q, where: ilike(field(users, ^field), ^"%#{value}%"))
    end)
  end

  defp maybe_filter_by_name_query(query, opts) do
    if Keyword.has_key?(opts, :name) do
      name = Keyword.get(opts, :name)
      from(user in query, where: ilike(user.canonical, ^"%#{name}%"))
    end || query
  end

  defp maybe_preload_query(query, opts) do
    preloads = Keyword.get(opts, :preload)

    if Keyword.has_key?(opts, :preload) do
      from(user in query, preload: ^preloads)
    end || query
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs, url_provider) do
    user_changeset = User.registration_changeset(%User{}, attrs)

    multi =
      Multi.new()
      |> Multi.insert(:user, user_changeset)
      |> Multi.run(:meta, &attach_meta_multi/2)
      |> Multi.run(:role, &attach_role_multi/2)
      |> Multi.run(:settings, &attach_settings_multi/2)
      |> Multi.run(:notify, fn _repo, %{user: user} ->
        deliver_user_confirmation_instructions(user, &url_provider.confirmation/1)
      end)

    case Repo.transaction(multi) do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, :user, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp attach_role_multi(_repo, %{user: user}) do
    role = Roles.get!("member")
    Roles.attach_role(role.id, user.id)
  end

  defp attach_meta_multi(repo, %{user: user}) do
    meta_changeset =
      %Meta{user_id: user.id}
      |> Meta.changeset(%{})

    repo.insert(meta_changeset)
  end

  defp attach_settings_multi(repo, %{user: user}) do
    settings_changeset =
      %Setting{user_id: user.id}
      |> Setting.changeset(%{})

    repo.insert(settings_changeset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = user |> User.email_changeset(%{email: email}) |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Updating user
  def update_user(%User{} = user, attrs, opts \\ []) do
    user
    |> update_roles(opts)
    # TODO update to use the new User module
    |> User.Old.changeset(attrs)
    |> Repo.update()
  end

  defp update_roles(user, opts) do
    if Keyword.has_key?(opts, :roles) do
      user =
        if not Ecto.assoc_loaded?(user.roles) do
          user |> Repo.preload(:roles)
        end || user

      new_roles = Keyword.get(opts, :roles)

      if not is_nil(new_roles) do
        Roles.update_roles(new_roles, user)
      end

      user
    end || user
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Same as 'generate_user_session_token/1' but accepts an additional user_agent
  metadata.
  """
  def generate_user_session_token_with_user_agent(user, user_agent) do
    {token, user_token} = UserToken.build_session_token(user)
    user_token = Map.put(user_token, :metadata, %{"user_agent" => user_agent})
    token_record = Repo.insert!(user_token)

    Phoenix.PubSub.broadcast(Embers.PubSub, @topic, {:session, :created, token_record})

    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    Repo.one(query)
    |> Embers.Profile.load_profile_for_user()
    |> load_stats_map()
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    Phoenix.PubSub.broadcast(Embers.PubSub, @topic, {:session, :deleted, token})
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Loads the count of users following it in the `following` field
  """
  def load_following_status(%User{} = user, follower_id) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^follower_id)
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    %{user | following: count > 0}
  end

  @doc """
  Loads the count of users that follow the user in the `following` field
  """
  def load_follows_me_status(%User{} = user, follower_id) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.source_id == ^follower_id)
      |> where([s], s.user_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    %{user | follows_me: count > 0}
  end

  @doc """
  If the following user has blocked the user, set the `blocked` field to `true`
  """
  def load_blocked_status(%User{} = user, follower_id) do
    count =
      Embers.Blocks.UserBlock
      |> where([b], b.user_id == ^follower_id)
      |> where([b], b.source_id == ^user.id)
      |> select([b], count(b.id))
      |> Embers.Repo.one()

    %{user | blocked: count > 0}
  end

  @doc """
    Loads the user stats
  """
  def load_stats_map(%User{} = user) do
    stats = %{
      followers: get_followers_count(user),
      following: get_following_count(user),
      posts: get_posts_count(user),
      comments: get_comments_count(user)
    }

    %{user | stats: stats}
  end

  def load_stats_map(other), do: other

  @doc """
  Gets the count of users following the user
  """
  def get_followers_count(%User{} = user) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.source_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  @doc """
  Gets the count of friends
  """
  def get_following_count(%User{} = user) do
    count =
      Embers.Subscriptions.UserSubscription
      |> where([s], s.user_id == ^user.id)
      |> select([s], count(s.id))
      |> Embers.Repo.one()

    count
  end

  @doc """
  Gets the count of posts made by the user
  """
  def get_posts_count(%User{} = user) do
    from(p in Embers.Posts.Post,
      where: p.user_id == ^user.id,
      where: is_nil(p.deleted_at),
      where: p.nesting_level == 0,
      select: count(p.id)
    )
    |> Embers.Repo.one()
  end

  @doc """
  Gets the count of comments made by the user
  """
  def get_comments_count(%User{} = user) do
    from(p in Embers.Posts.Post,
      where: p.user_id == ^user.id,
      where: is_nil(p.deleted_at),
      where: p.nesting_level > 0,
      select: count(p.id)
    )
    |> Embers.Repo.one()
  end
end
