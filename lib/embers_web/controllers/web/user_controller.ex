defmodule EmbersWeb.UserController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Accounts

  plug(:id_check when action in [:edit, :update, :delete])

  def show(%Plug.Conn{assigns: %{current_user: current_user}} = conn, %{"id" => id})
      when not is_nil(current_user) do
    case Accounts.get_populated(id) do
      nil ->
        conn |> put_status(:not_found) |> json(:not_found)

      user ->
        user =
          user
          |> Accounts.load_following_status(current_user.id)
          |> Accounts.load_follows_me_status(current_user.id)
          |> Accounts.load_blocked_status(current_user.id)

        render(conn, "show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_populated(id) do
      nil ->
        conn |> put_status(:not_found) |> json(:not_found)

      user ->
        render(conn, "show.json", user: user)
    end
  end

  def reset_pass(conn, _params) do
    email = conn.assigns.current_user.email

    if Accounts.create_password_reset(%{"email" => email}) do
      key = EmbersWeb.Auth.Token.sign(%{"email" => email})
      EmbersWeb.Email.reset_request(email, key)
    end

    conn |> put_status(:no_content) |> json(nil)
  end
end
