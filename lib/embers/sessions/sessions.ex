defmodule Embers.Sessions do
  @moduledoc """
  The Sessions context
  """

  @moduledoc deprecated: "Use `Embers.Accounts.Sessions` instead"

  import Ecto.Query, warn: false

  alias Embers.Accounts.User
  alias Embers.Repo
  alias Embers.Sessions.Session

  @doc """
  Returns a list of sessions for the user.
  """
  def list_sessions(%User{} = user) do
    sessions = Repo.preload(user, :sessions).sessions
    Enum.filter(sessions, &(&1.expires_at > DateTime.utc_now()))
  end

  @doc """
  Gets a single user.
  """
  def get_session(nil), do: nil

  def get_session(id) do
    now = DateTime.utc_now()
    Repo.one(from(s in Session, where: s.id == ^id and s.expires_at > ^now, limit: 1))
  end

  @doc """
  Creates a session.
  """
  def create_session(attrs \\ %{}) do
    %Session{} |> Session.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Deletes a session.
  """
  def delete_session(nil), do: nil

  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Deletes all a user's sessions.
  """
  def delete_user_sessions(user_id) when is_binary(user_id) do
    Repo.delete_all(from(s in Session, where: s.user_id == ^user_id), returning: true)
  end

  def delete_user_sessions(%User{} = user) do
    delete_user_sessions(user.id)
  end

  def delete_expired() do
    from(session in Session, where: session.expires_at < ^DateTime.utc_now())
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end
end
