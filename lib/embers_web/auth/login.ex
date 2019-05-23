defmodule EmbersWeb.Auth.Login do
  @moduledoc """
  Custom login module that checks if the user is confirmed before
  allowing the user to log in.
  """

  use Phauxth.Login.Base

  alias Embers.Accounts
  alias Phauxth.Remember
  alias Embers.Sessions

  import EmbersWeb.Gettext

  @impl true
  def authenticate(%{"password" => password} = params, _, opts) do
    case Accounts.get_by(params) do
      nil -> {:error, gettext("no user found")}
      %{confirmed_at: nil} -> {:error, gettext("account unconfirmed")}
      user -> Pbkdf2.check_pass(user, password, opts)
    end
  end

  def add_session(conn, user, params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
    |> add_remember_me(user.id, params)
  end

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn
end
