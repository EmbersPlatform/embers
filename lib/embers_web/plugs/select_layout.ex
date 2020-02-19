defmodule EmbersWeb.Plugs.SelectLayout do
  import Phoenix.Controller, only: [put_layout: 2]

  def init(default), do: default

  def call(%{assigns: %{current_user: nil}} = conn, _opts) do
    put_layout(conn, {EmbersWeb.LayoutView, "guest.html"})
  end

  def call(conn, _opts) do
    put_layout(conn, {EmbersWeb.LayoutView, "logged_in.html"})
  end
end
