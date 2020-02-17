defmodule EmbersWeb.ConfirmController do
  @moduledoc false

  use EmbersWeb, :controller
  alias Embers.Accounts
  alias EmbersWeb.Email
  alias EmbersWeb.Router.Helpers, as: Routes
  alias Phauxth.Confirm

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        Email.confirm_success(user.email)

        conn
        |> put_flash(:info, "Tu cuenta ha sido confirmada, ¡Ya puedes iniciar sesión!")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end
end
