defmodule EmbersWeb.Plugs.CheckPermissions do
  import Plug.Conn
  alias Embers.Authorization

  import Phoenix.Controller
  alias EmbersWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(
        %Plug.Conn{assigns: %{permissions: permissions}} = conn,
        options
      ) do
    permission = Keyword.get(options, :permission)

    case Authorization.check_permission(permissions, permission) do
      :ok ->
        conn

      :denegated ->
        conn
        |> put_status(:forbidden)
        |> json(:forbidden)
        |> halt()
    end
  end
end
