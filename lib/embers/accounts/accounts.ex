defmodule Embers.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Phauxth.Log
  alias Embers.{Accounts.User, Profile.Settings.Setting, Profile.Meta, Repo}
  alias Ecto.Multi

  def list_users do
    Repo.all(User)
  end

  def get(id), do: Repo.get(User, id)

  def get_by_identifier(identifier) do
    case Float.parse(identifier) do
      {_id, ""} -> get(identifier)
      _ -> get_by(%{"canonical" => identifier})
    end
  end

  def get_populated(identifier) do
    query =
      case Integer.parse(identifier) do
        {_id, ""} -> User |> where([user], user.id == ^identifier)
        _ -> User |> where([user], user.canonical == ^identifier)
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

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def get_by(%{"username" => username}) do
    Repo.get_by(User, username: username)
  end

  def get_by(%{"canonical" => canonical}) do
    Repo.get_by(User, canonical: canonical)
  end

  def create_user(attrs) do
    user_changeset = User.create_changeset(%User{}, attrs)

    multi =
      Multi.new()
      |> Multi.insert(:user, user_changeset)
      |> Multi.run(:meta, fn %{user: user} ->
        meta_changeset =
          %Meta{user_id: user.id}
          |> Meta.changeset(%{})

        Repo.insert(meta_changeset)
      end)
      |> Multi.run(:settings, fn %{user: user} ->
        settings_changeset =
          %Setting{user_id: user.id}
          |> Setting.changeset(%{})

        Repo.insert(settings_changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, results} ->
        {:ok, results.user}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def confirm_user(%User{} = user) do
    change(user, %{confirmed_at: DateTime.utc_now()}) |> Repo.update()
  end

  def create_password_reset(endpoint, attrs) do
    with %User{} = user <- get_by(attrs) do
      change(user, %{reset_sent_at: DateTime.utc_now()}) |> Repo.update()
      Log.info(%Log{user: user.id, message: "password reset requested"})
      Phauxth.Token.sign(endpoint, attrs)
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_password(%User{} = user, attrs) do
    user
    |> User.create_changeset(attrs)
    |> change(%{reset_sent_at: nil, sessions: %{}})
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_sessions(user_id) do
    with user when is_map(user) <- Repo.get(User, user_id), do: user.sessions
  end

  def add_session(%User{sessions: sessions} = user, session_id, timestamp) do
    change(user, sessions: put_in(sessions, [session_id], timestamp))
    |> Repo.update()
  end

  def delete_session(%User{sessions: sessions} = user, session_id) do
    change(user, sessions: Map.delete(sessions, session_id))
    |> Repo.update()
  end

  def remove_old_sessions(session_age) do
    now = System.system_time(:second)

    Enum.map(
      list_users(),
      &(change(
          &1,
          sessions:
            :maps.filter(
              fn _, time ->
                time + session_age > now
              end,
              &1.sessions
            )
        )
        |> Repo.update())
    )
  end
end
