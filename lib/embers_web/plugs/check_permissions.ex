defmodule EmbersWeb.Plugs.CheckPermissions do
  import Plug.Conn
  alias Embers.Authorization

  import Phoenix.Controller

  def init(default), do: default

  def call(
        %{assigns: %{current_user: %{permissions: permissions}}} = conn,
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
