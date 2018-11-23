defmodule EmbersWeb.SessionController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Phauxth.Remember
  alias Embers.Sessions
  alias EmbersWeb.Auth.Login
  alias EmbersWeb.Router.Helpers, as: Routes

  plug(:guest_check when action in [:new, :create])
  plug(:put_layout, "app_no_js.html")

  def new(conn, _) do
    render(conn, "new.html")
  end

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"id" => identifier, "password" => password}) do
    user_params =
      case Regex.match?(~r/@/, identifier) do
        true -> %{"email" => identifier, "password" => password}
        false -> %{"canonical" => identifier, "password" => password}
      end

    case Login.verify(user_params, crypto: Comeonin.Pbkdf2) do
      {:ok, user} ->
        conn
        |> add_session(user, user_params)
        |> put_flash(:info, "User successfully logged in.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, _params) do
    session_id = get_session(conn, :phauxth_session_id)

    case session_id |> Sessions.get_session() |> Sessions.delete_session() do
      {:ok, %{user_id: ^user_id}} ->
        conn
        |> delete_session(:phauxth_session_id)
        |> Remember.delete_rem_cookie()
        |> put_status(:no_content)
        |> json(nil)

      _ ->
        conn
        |> json(%{error: "unauthorized"})
    end
  end

  defp add_session(conn, user, params) do
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
