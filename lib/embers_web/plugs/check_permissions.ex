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
        |> forbidden_or_404(options)
        |> halt()
    end
  end

  def call(conn, options) do
    conn
    |> forbidden_or_404(options)
    |> halt()
  end

  defp forbidden_or_404(conn, options) do
    as_404? = Keyword.get(options, :as_404?, true)

    if as_404? do
      conn
      |> Phoenix.Controller.render(EmbersWeb.ErrorView, :"404")
    else
      conn
      |> put_status(:forbidden)
      |> json(:forbidden)
    end
  end
end
