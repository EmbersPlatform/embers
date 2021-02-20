defmodule EmbersWeb.Moderation.RoleController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Authorization.Roles

  action_fallback(EmbersWeb.FallbackController)

  def index(conn, _params) do
    roles = Roles.list_all()

    render(conn, "index.html", roles: roles)
  end

  def update(conn, %{"role_id" => role_id} = params) do
    with role when not is_nil(role) <- Roles.get_by_id(role_id),
         name = Map.get(params, "name", role.name),
         permissions = Map.get(params, "permissions", role.permissions),
         {:ok, role} <- Roles.update(role.name, %{name: name, permissions: permissions}) do
      render(conn, "role.json", role: role)
    else
      nil -> {:error, :not_found}
    end
  end
end
