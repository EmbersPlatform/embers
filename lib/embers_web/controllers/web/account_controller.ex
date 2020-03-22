defmodule EmbersWeb.Web.AccountController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Accounts
  alias EmbersWeb.Auth.Token
  alias EmbersWeb.Email
  alias EmbersWeb.Router.Helpers, as: Routes

  plug(:guest_check when action in [:new, :create])

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", page_title: "Registrarse", changeset: changeset)
  end

  def create(conn, params) do
    email = get_in(params, ["user", "email"])

    with {:ok, _} <- Recaptcha.verify(params["g-recaptcha-response"]),
         {:ok, _user} <- Accounts.create_user(params["user"]) do
      send_confirmation_email(email)

      conn
      |> put_flash(
        :info,
        "Tu cuenta ha sido creada, pero antes debes activarla.
        Te enviamos un email con un enlace para activarla."
      )
      |> redirect(to: Routes.session_path(conn, :new))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Hubo un error al crear la cuenta, por favor revisa
          los errores debajo.")
        |> render("new.html", page_title: "Registrarse", changeset: changeset)

      {:error, errors} ->
        conn
        |> put_flash(:error, errors)
        |> redirect(to: Routes.account_path(conn, :new))
    end
  end

  defp send_confirmation_email(email) do
    key = Token.sign(%{"email" => email})
    Email.confirm_request(email, key)
  end
end
