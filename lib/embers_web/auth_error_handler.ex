defmodule EmbersWeb.AuthErrorHandler do
  use EmbersWeb, :controller

  alias EmbersWeb.Router.Helpers, as: Routes

  def call(conn, :not_authenticated) do
    conn
    |> put_flash(:error, "You've to be authenticated first")
    |> redirect(to: Routes.login_path(conn, :new))
  end

  def call(conn, :already_authenticated) do
    conn
    |> put_flash(:error, "You're already authenticated")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
