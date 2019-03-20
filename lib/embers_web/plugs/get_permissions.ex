defmodule EmbersWeb.Plugs.GetPermissions do
  import Plug.Conn
  alias Embers.Authorization

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{current_user: user}} = conn, _default) when not is_nil(user) do
    permissions = Authorization.extract_permissions(user)
    assign(conn, :permissions, permissions)
  end

  def call(conn, _default) do
    assign(conn, :permissions, [])
  end
end
