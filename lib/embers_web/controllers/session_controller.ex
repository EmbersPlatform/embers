defmodule EmbersWeb.SessionController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Accounts
  alias Phauxth.Confirm.Login

  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    render(conn, "new.html")
  end

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"id" => identifier, "password" => password}) do
    user_params = case Regex.match?(~r/@/, identifier) do
      true -> %{"email" => identifier, "password" => password}
      false -> %{"canonical" => identifier, "password" => password}
    end

    case Login.verify(user_params, Accounts, crypto: Comeonin.Pbkdf2 ) do
      {:ok, user} ->
        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))

        Login.add_session(conn, session_id, user.id)
        |> render(EmbersWeb.UserView, "user.json", user: user)

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> render(EmbersWeb.ErrorView, "401.json", message: message)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    <<session_id::binary-size(17), _::binary>> = get_session(conn, :phauxth_session_id)
    Accounts.delete_session(user, session_id)

    delete_session(conn, :phauxth_session_id)
    |> Phauxth.Remember.delete_rem_cookie()
    |> success("You have been logged out", page_path(conn, :index))
  end

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Phauxth.Remember.add_rem_cookie(conn, user_id)
  end
  defp add_remember_me(conn, _, _), do: conn
end
