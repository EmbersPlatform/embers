defmodule Embers.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Ecto.Multi

  alias Embers.{
    Accounts.User,
    Profile.Settings.Setting,
    Sessions,
    Sessions.Session,
    Profile.Meta,
    Repo
  }

  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  def get_by_identifier(identifier) do
    case Float.parse(identifier) do
      {_id, ""} -> get_user(identifier)
      _ -> get_by(%{"canonical" => identifier})
    end
  end

  def get_populated(identifier) do
    query =
      case is_integer(identifier) do
        true -> User |> where([user], user.id == ^identifier)
        false -> User |> where([user], user.canonical == ^identifier)
      end

    user =
      query
      |> join(:left, [user], meta in assoc(user, :meta))
      |> preload([user, meta], meta: meta)
      |> Repo.one()

    user = user |> User.populate()
    user = %{user | meta: user.meta |> Meta.populate()}

    user
  end

  @doc """
  Gets a user based on the params.
  This is used by Phauxth to get user information.
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

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
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
