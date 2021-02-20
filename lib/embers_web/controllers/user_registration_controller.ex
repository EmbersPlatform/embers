defmodule EmbersWeb.UserRegistrationController do
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Accounts.User
  alias EmbersWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params, EmbersWeb.UrlProvider) do
      {:ok, user} ->
        conn
        |> put_flash(
          :info,
          gettext(
            "Your account has been created. We've sent you an email with a confirmation link to activate it."
          )
        )
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
