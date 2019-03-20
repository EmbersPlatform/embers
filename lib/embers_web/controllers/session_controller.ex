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

  # If you are using Argon2 or Pbkdf2, add crypto: Argon2
  # or crypto: Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"id" => identifier, "password" => password}) do
    user_params =
      case Regex.match?(~r/@/, identifier) do
        true -> %{"email" => identifier, "password" => password}
        false -> %{"canonical" => identifier, "password" => password}
      end

    case Login.verify(user_params, crypto: Pbkdf2) do
      {:ok, user} ->
        conn
        |> Login.add_session(user, user_params)
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

  def create_api(conn, %{"id" => identifier, "password" => password}) do
    case conn.assigns.current_user do
      nil ->
        user_params =
          case Regex.match?(~r/@/, identifier) do
            true -> %{"email" => identifier, "password" => password}
            false -> %{"canonical" => identifier, "password" => password}
          end

        case Login.verify(user_params, crypto: Pbkdf2) do
          {:ok, user} ->
            conn
            |> Login.add_session(user, user_params)
            |> put_status(:no_content)
            |> json(%{message: :success})

          {:error, message} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: :invalid_credentials})
        end

      user ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: :already_logged_in})
    end
  end
end
