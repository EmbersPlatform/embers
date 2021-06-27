defmodule Embers.Authorization.Roles do
  @moduledoc """
  Roles(or groups) are permission containers. They're just a list of permissions
  associated to a name.

  Permissions are any arbitrary string, they're not checked.
  """

  alias Embers.Accounts.User
  alias Embers.Authorization.{Role, RoleUser}
  alias Embers.Repo

  import Ecto.Query, only: [from: 2]

  @doc """
    Returns a list with all the stored roles
  """
  def list_all do
    Repo.all(Role)
  end

  @doc """
    Gets a role by it's id, or `nil` if none is found
  """
  def get_by_id(id) do
    Repo.get_by(Role, id: id)
  end

  @doc """
    Gets a role by it's name, nor `nil` if none is found
  """
  @spec get(String.t()) :: Role.t() | nil
  def get(name) do
    Repo.one(
      from(role in Role,
        where: role.name == ^name
      )
    )
  end

  @doc """
    Same as `get/1` but raises if no role was found
  """
  @spec get!(String.t()) :: Role.t()
  def get!(name) do
    Repo.one!(
      from(role in Role,
        where: role.name == ^name
      )
    )
  end

  @doc """
    Creates a role with the `name` and `permissions`
  """
  @spec create(String.t(), [String.t()]) :: Role.t()
  def create(name, permissions \\ []) do
    changeset = Role.changeset(%Role{}, %{name: name, permissions: permissions})
    Repo.insert(changeset)
  end

  @doc """
    Updates the `name` role.
  """
  @spec update(String.t(), map()) :: Role.t()
  def update(name, attrs) do
    role = get(name)
    role = Role.changeset(role, attrs)
    Repo.update(role)
  end

  @doc """
  Deletes the role by it's `name`
  """
  @spec delete(String.t()) :: Role.t() | nil
  def delete(name) do
    role = get(name)
    Repo.delete(role)
  end

  @doc """
  Gets the roles for the user, or fetchs them from db if not loaded
  """
  @spec roles_for(User.t() | integer) :: [Role.t()]
  def roles_for(%User{} = user) do
    if Ecto.assoc_loaded?(user.roles) do
      user.roles
    else
      roles_for(user.id)
    end
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

  @doc """
  Attachs a role to a user.
  Returns the `RoleUser` representing the association.
  """
  def attach_role(role, user)

  @spec attach_role(String.t(), String.t()) :: RoleUser.t() | nil
  def attach_role(role_id, user_id) when is_binary(role_id) and is_binary(user_id) do
    changeset = RoleUser.changeset(%RoleUser{}, %{role_id: role_id, user_id: user_id})
    Repo.insert(changeset)
  end

  @spec attach_role(Role.t(), User.t()) :: RoleUser.t() | nil
  def attach_role(%Role{} = role, %User{} = user) do
    attach_role(role.id, user.id)
  end

  @doc """
  Detachs the role form the user.
  Returns the `RoleUser` that did represent the association.
  """
  def detach_role(role_id, user_id) when is_binary(role_id) and is_binary(user_id) do
    case Repo.get_by(RoleUser, %{role_id: role_id, user_id: user_id}) do
      nil -> nil
      role -> Repo.delete(role)
    end
  end

  def detach_role(%Role{} = role, %User{} = user) do
    detach_role(role.id, user.id)
  end

  @doc """
  Updates the user roles by diffing the `new_roles` with the current roles.
  """
  def update_roles(new_roles, user) when is_list(new_roles) do
    old_roles = user.roles |> Enum.map(fn role -> role.id end)
    Enum.each(new_roles -- old_roles, &attach_role(&1, user.id))
    Enum.each(old_roles -- new_roles, &detach_role(&1, user.id))
  end
end
