defmodule EmbersWeb.AccountController do
  @moduledoc false
  use EmbersWeb, :controller
  import EmbersWeb.Authorize
  alias Embers.Accounts
  alias EmbersWeb.Auth.Token
  alias EmbersWeb.Email
  alias EmbersWeb.Router.Helpers, as: Routes
  alias Phauxth.Log

  plug(:guest_check when action in [:new, :create])
  plug(:put_layout, "app_no_js.html")

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", page_title: "Registrarse", changeset: changeset)
  end

  def create(
        conn,
        %{
          "user" => %{
            "email" => email
          }
        } = params
      ) do
    case Recaptcha.verify(params["g-recaptcha-response"]) do
      {:ok, _} ->
        case Accounts.create_user(params["user"]) do
          {:ok, user} ->
            Log.info(%Log{user: user.id, message: "user created"})
            key = Token.sign(%{"email" => email})
            Email.confirm_request(email, key)

            conn
            |> put_flash(
              :info,
              "Tu cuenta ha sido creada, pero antes debes activarla. Te enviamos un email con un enlace para activarla."
            )
            |> redirect(to: Routes.login_path(conn, :new))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", page_title: "Registrarse", changeset: changeset)
        end

      {:error, errors} ->
        conn
        |> put_flash(:error, errors)
        |> redirect(to: Routes.account_path(conn, :new))
    end
  end
end
