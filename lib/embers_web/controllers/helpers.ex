defmodule EmbersWeb.Helpers do
  @moduledoc false

  import Plug.Conn
  import Phoenix.Controller

  def success(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end

  def error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end
end
