defmodule EmbersWeb.Admin.RoleController do
  use EmbersWeb, :controller

  import Ecto.Query
  import EmbersWeb.Helpers
  alias Embers.Repo
  alias Embers.Authorization
  alias Embers.Authorization.{Role, Roles}

  plug(:put_layout, "dashboard.html")

  def index(conn, _params) do
    roles_list = get_roles()

    render(conn, "list.html", %{roles: roles_list})
  end

  def new(conn, _params) do
    changeset = Role.changeset(%Role{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"role" => %{"permissions" => permissions, "name" => name}} = _params) do
    IO.inspect(permissions)

    case Roles.create(name, permissions) do
      {:ok, _role} ->
        success(conn, "Rol creado!", role_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Hubo un error al crear el rol")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"rolename" => rolename}) do
    role = Roles.get(rolename)
    changeset = Role.changeset(role, %{})
    render(conn, "edit.html", changeset: changeset, role: role)
  end

  def update(
        conn,
        %{"rolename" => rolename, "role" => %{"permissions" => permissions, "name" => name}} =
          _params
      ) do
    role = Roles.get(rolename)

    case Roles.update(role.name, %{name: name, permissions: permissions}) do
      {:ok, _role} ->
        success(conn, "Rol actualizado!", role_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Hubo un error al actualizar el rol")
        |> render("edit.html", changeset: changeset, role: role)
    end
  end

  def destroy(conn, %{"name" => name}) do
    case Roles.delete(name) do
      {:ok, _role} ->
        success(conn, "Rol eliminado!", role_path(conn, :index))

      {:error, _reason} ->
        error(conn, "Hubo un error al eliminar el post", role_path(conn, :index))
    end
  end

  defp get_roles() do
    from(role in Role)
    |> Repo.all()
  end
end
