defmodule Embers.Accounts do
  @moduledoc """
  La interfaz para las cuentas.
  Las cuentas en este caso son lo mismo que los usuarios.

  ## Confirmación de cuentas
  Embers requiere que las cuentas sean confirmadas para poder ser usadas.
  Una cuenta sin confirmar será rechazada a la hora de iniciar sesión.

  Para confirmar una cuenta, basta con asignarle una fecha al campo
  `:confirmed_at`, mediante la función `confirm_user/1`.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Ecto.Multi

  alias Embers.{
    Accounts.User,
    Authorization.Roles,
    Paginator,
    Profile.Meta,
    Profile.Settings.Setting,
    Repo,
    Sessions
  }

  @doc """
  Devuelve todos los usuarios existentes.
  Es preferible utilizar `list_users_paginated/1` ya que esta función no es
  capaz de dividir los resultados en fragmentos mas pequeños.

  ## Ejemplo
      iex> list_users()
      [%User{}, ...]
  """
  def list_users(_opts \\ []) do
    Repo.all(User)
  end

  @doc """
  Devuelve un conjunto de los usuarios existentes.

  ## Ejemplo
      iex> list_users_paginated()
      %Page{
        entries: [%User{}, ...],
        last_page: false,
        next: "next cursor"
      }

  ## Opciones
  Además de las opciones aceptadas por `Embers.Paginator.paginate/2`, acepta
  las siguientes opciones:

  - `:name`: Si es especificado, se buscaran todos los usuarios que contengan
  este valor en el campo `canonical`.
  """
  @spec list_users_paginated(keyword()) :: Embers.Paginator.Page.t()
  def list_users_paginated(opts \\ []) do
    order = Keyword.get(opts, :order, :asc)
    query =
      from(
        users in User,
        order_by: [{^order, users.inserted_at}],
        preload: [:meta]
      )
      |> maybe_filter_by_name_query(opts)
      |> maybe_preload_query(opts)

    Paginator.paginate(query, opts)
    |> Paginator.map(fn user ->
      user
      |> Map.update!(:meta, &Embers.Profile.Meta.load_avatar_map/1)
      |> Map.update!(:meta, &Embers.Profile.Meta.load_cover/1)
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

  @doc """
  Devuelve un usuario de acuerdo al `id` proporcionado.

  ## Ejemplos
      iex> get_user(1)
      %User{}
      iex> get_user(0)
      nil
  """
  @spec get_user(integer()) :: Embers.Accounts.User.t() | nil
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Devuelve un usuario basado en el id o nombre de usuario provisto.

  ## Ejemplos
      iex> get_by_identifier(1)
      %User{}
      iex> get_by_identifier("jane")
      %User{}
  """
  def get_by_identifier(identifier) when is_binary(identifier) do
    get_by(%{"canonical" => identifier})
  end

  def get_by_identifier(identifier) when is_integer(identifier) do
    get_user(identifier)
  end

  @doc """
  Similar a `get_by_identifier/1` pero devuelve al usuario con su `:meta` y `:settings`.
  """
  def get_populated(identifier, opts \\ []) do
    query =
      case identifier do
        %{"canonical" => canonical} ->
          from(user in User, where: user.canonical == ^canonical)
        id when is_binary(id) ->
          from(user in User, where: user.id == ^id)
      end

    user =
      query
      |> join(:left, [user], meta in assoc(user, :meta))
      |> preload([user, meta], meta: meta)
      |> Repo.one()

    user =
      if Keyword.get(opts, :with_settings, false) do
        Repo.preload(user, :settings)
      end || user

    case user do
      nil ->
        nil

      user ->
        user = user |> Embers.Accounts.load_stats_map()
        user = %{user | meta: user.meta |> Meta.populate()}

        user
    end
  end

  @doc """
  Devuelve al usuaro basado en el campo provisto.
  """
  def get_by(%{"session_id" => session_id}) do
    with %{user_id: user_id} <- Sessions.get_session(session_id), do: get_user(user_id)
  end

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  def get_by(%{"username" => username}) do
    Repo.get_by(User, username: username)
  end

  def get_by(%{"canonical" => canonical}) do
    Repo.get_by(User, canonical: canonical)
  end

  @doc """
  Crea a un usuario y a las entidades asociadas.

  Al crear a un usuario, se crean tambien su `Meta` y `Settings`,
  y se le asigna el rol "member" para que pueda realizar todas las acciones
  básicas.

  Al realizarse dentro de una transacción, si alguna de las operaciones falla,
  se da marcha atrás a la operación completa y se devolverá el error ocurrido.
  """
  def create_user(attrs) do
    user_changeset = User.create_changeset(%User{}, attrs)

    multi =
      Multi.new()
      |> Multi.insert(:user, user_changeset)
      |> Multi.run(:role, &multi_attach_role/2)
      |> Multi.run(:meta, &multi_attach_meta/2)
      |> Multi.run(:settings, &multi_attach_settings/2)

    case Repo.transaction(multi) do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp multi_attach_role(_repo, %{user: user}) do
    role = Roles.get!("member")
    Roles.attach_role(role.id, user.id)
  end

  defp multi_attach_meta(repo, %{user: user}) do
    meta_changeset =
      %Meta{user_id: user.id}
      |> Meta.changeset(%{})

    repo.insert(meta_changeset)
  end

  defp multi_attach_settings(repo, %{user: user}) do
    settings_changeset =
      %Setting{user_id: user.id}
      |> Setting.changeset(%{})

    repo.insert(settings_changeset)
  end

  def update_user(%User{} = user, attrs, opts \\ []) do
    user
    |> update_roles(opts)
    |> User.changeset(attrs)
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

  @doc """
  Confirms a user's email.
  """
  def confirm_user(%User{} = user) do
    user |> User.confirm_changeset() |> Repo.update()
  end

  @doc """
  Makes a password reset request.
  """
  def create_password_reset(attrs) do
    with %User{} = user <- get_by(attrs) do
      user
      |> User.password_reset_changeset(DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end

  @doc """
  Updates a user's password.
  """
  def update_password(%User{} = user, attrs) do
    Sessions.delete_user_sessions(user)

    user
    |> User.create_changeset(attrs)
    |> User.password_reset_changeset(nil)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
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
