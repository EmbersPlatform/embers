defmodule Embers.Authorization.Roles do
  alias Embers.Authorization.{Role, RoleUser}
  alias Embers.Repo

  import Ecto.Query, only: [from: 2]

  def get(name) do
    from(role in Role,
      where: role.name == ^name
    )
    |> Repo.one()
  end

  def get!(name) do
    from(role in Role,
      where: role.name == ^name
    )
    |> Repo.one!()
  end

  def create(name, permissions \\ []) do
    Role.changeset(%Role{}, %{name: name, permissions: permissions})
    |> Repo.insert()
  end

  def update(name, attrs) do
    role = get(name)
    role = Role.changeset(role, attrs)
    Repo.update(role)
  end

  def delete(name) do
    role = get(name)
    Repo.delete(role) |> IO.inspect()
  end

  def roles_for(user_id) do
    from(ru in RoleUser,
      where: ru.user_id == ^user_id,
      left_join: role in assoc(ru, :role),
      select: role
    )
    |> Repo.all()
  end

  def attach_role(role_id, user_id) do
    RoleUser.changeset(%RoleUser{}, %{role_id: role_id, user_id: user_id})
    |> Repo.insert()
  end
end
