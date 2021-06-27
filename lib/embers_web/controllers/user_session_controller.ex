defmodule EmbersWeb.UserSessionController do
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias EmbersWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"identifier" => identifier, "password" => password} = user_params

    conn = conn |> assign(:page_title, gettext("Log in"))

    with user when not is_nil(user) <-
           Accounts.get_user_by_username_or_email_and_password(identifier, password),
         :ok <- UserAuth.check_confirmed_user(user),
         :ok <- UserAuth.check_not_banned(user) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      nil ->
        render(conn, "new.html", error_message: "Invalid email or password")

      {:error, message} ->
        render(conn, "new.html", error_message: message)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
