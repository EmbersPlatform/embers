defmodule EmbersWeb.Plugs.Permissions do
  import Plug.Conn
  import Phoenix.Controller
  alias Embers.Authorization
  alias EmbersWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{current_user: user}} = conn, _default) when not is_nil(user) do
    permissions = Authorization.extract_permissions(user)
    assign(conn, :permissions, permissions)
  end

  def call(conn, _default) do
    assign(conn, :permissions, [])
  end

  def check_permission(
        %Plug.Conn{assigns: %{permissions: permissions}} = conn,
        permission
      ) do
    case Authorization.check_permission(permissions, permission) do
      :ok ->
        conn

      :denegated ->
        conn
        |> put_status(:unauthorized)
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
    end
  end
end
