defmodule Embers.Authorization.Roles do
  @moduledoc """
  Los roles son los contenedores para los permisos. Sólo tienen un nombre y una
  lista de permisos.

  Un usuario puede tener muchos roles, lo que hace más fácil definirlos.
  Por ejemplo, un miembro tiene el set de permisos básicos. Para que sea
  un moderador, en vez de volver a definir los permisos basta con definir
  sólo los que son específicos a la moderación. Los permisos totales que posee
  un usuario resultan de la suma de los permisos de todos sus roles.
  """

  alias Embers.Accounts.User
  alias Embers.Authorization.{Role, RoleUser}
  alias Embers.Repo

  import Ecto.Query, only: [from: 2]

  def list_all do
    Repo.all(Role)
  end

  def get(name) do
    Repo.one(
      from(role in Role,
        where: role.name == ^name
      )
    )
  end

  def get!(name) do
    Repo.one!(
      from(role in Role,
        where: role.name == ^name
      )
    )
  end

  def create(name, permissions \\ []) do
    changeset = Role.changeset(%Role{}, %{name: name, permissions: permissions})
    Repo.insert(changeset)
  end

  def update(name, attrs) do
    role = get(name)
    role = Role.changeset(role, attrs)
    Repo.update(role)
  end

  def delete(name) do
    role = get(name)
    Repo.delete(role)
  end

  def roles_for(user_id) do
    Repo.all(
      from(ru in RoleUser,
        where: ru.user_id == ^user_id,
        left_join: role in assoc(ru, :role),
        select: role
      )
    )
  end

  def attach_role(role_id, user_id) when is_integer(role_id) and is_integer(user_id) do
    changeset = RoleUser.changeset(%RoleUser{}, %{role_id: role_id, user_id: user_id})
    Repo.insert(changeset)
  end

  def attach_role(%Role{} = role, %User{} = user) do
    attach_role(role.id, user.id)
  end

  def attach_role(rolename, user_id) when is_binary(rolename) and is_integer(user_id) do
    case get(rolename) do
      nil -> nil
      role -> attach_role(role.id, user_id)
    end
  end

  def attach_role(rolename, %User{} = user) when is_binary(rolename) do
    attach_role(rolename, user.id)
  end

  def detach_role(role_id, user_id) when is_integer(role_id) and is_integer(user_id) do
    case Repo.get_by(RoleUser, %{role_id: role_id, user_id: user_id}) do
      nil -> nil
      role -> Repo.delete(role)
    end
  end

  def detach_role(%Role{} = role, %User{} = user) do
    detach_role(role.id, user.id)
  end

  def detach_role(rolename, user_id) when is_binary(rolename) and is_integer(user_id) do
    case get(rolename) do
      nil -> nil
      role -> detach_role(role.id, user_id)
    end
  end

  def detach_role(rolename, %User{} = user) when is_binary(rolename) do
    detach_role(rolename, user.id)
  end

  def update_roles(new_roles, user) when is_list(new_roles) do
    old_roles = user.roles |> Enum.map(fn role -> role.id end)
    Enum.each(new_roles -- old_roles, &attach_role(&1, user.id))
    Enum.each(old_roles -- new_roles, &detach_role(&1, user.id))
  end
end
