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
    Sessions,
    Sessions.Session
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
    query = from(users in User)

    query =
      if Keyword.has_key?(opts, :name) do
        from(user in query, where: ilike(user.canonical, ^"%#{Keyword.get(opts, :name)}%"))
      end || query

    query =
      if Keyword.has_key?(opts, :preload) do
        from(user in query, preload: ^Keyword.get(opts, :preload))
      end || query

    Paginator.paginate(query, opts)
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
  Similar a `get_by_identifier/1` pero devuelve al usuario con su `:meta`.
  """
  def get_populated(identifier, opts \\ []) do
    query =
      case is_integer(identifier) do
        true -> User |> where([user], user.id == ^identifier)
        false -> User |> where([user], user.canonical == ^String.downcase(identifier))
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
        user = user |> User.populate()
        user = %{user | meta: user.meta |> Meta.populate()}

        user
    end
  end

  @doc """
  Devuelve al usuaro basado en el campo provisto.
  """
  def get_by(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id), do: get_user(user_id)
  end

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

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
  def create_user(attrs, opts \\ []) do
    raw = Keyword.get(opts, :raw, false)

    user_changeset =
      if raw do
        User.create_changeset_raw(%User{}, attrs)
      else
        User.create_changeset(%User{}, attrs)
      end

    multi =
      Multi.new()
      |> Multi.insert(:user, user_changeset)
      |> Multi.run(:role, fn _repo, %{user: user} ->
        role = Roles.get!("member")
        Roles.attach_role(role.id, user.id)
      end)
      |> Multi.run(:meta, fn repo, %{user: user} ->
        meta_changeset =
          %Meta{user_id: user.id}
          |> Meta.changeset(%{})

        repo.insert(meta_changeset)
      end)
      |> Multi.run(:settings, fn repo, %{user: user} ->
        settings_changeset =
          %Setting{user_id: user.id}
          |> Setting.changeset(%{})

        repo.insert(settings_changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, results} ->
        {:ok, results.user}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
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
end
