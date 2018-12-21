defmodule EmbersWeb.AuthCase do
  use Phoenix.ConnTest

  import Ecto.Changeset
  alias Embers.{Accounts, Repo}

  def add_user(username, email) do
    user = %{username: username, email: email, password: "reallyHard2gue$$"}
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_user_confirmed(username, email) do
    add_user(username, email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def add_reset_user(username, email) do
    add_user(username, email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def add_phauxth_session(conn, user) do
    session_id = Phauxth.Login.gen_session_id("F")
    Accounts.add_session(user, session_id, System.system_time(:second))
    Phauxth.Login.add_session(conn, session_id, user.id)
  end

  def gen_key(user_id) do
    EmbersWeb.Auth.Token.sign(%{"user_id" => user_id})
  end
end
