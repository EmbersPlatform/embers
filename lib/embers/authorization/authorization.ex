defmodule Embers.Authorization do
  @moduledoc """
  Módulo usado para checkear si un usuario es capaz de realizar una acción.
  """
  alias Embers.Accounts.User
  alias Embers.Authorization.Roles

  @doc """
  Devuelve si el usuario posee el permiso indicado.
  """
  @spec can?(String.t(), Embers.Accounts.User.t()) :: boolean()
  def can?(permission, user) do
    permissions = extract_permissions(user)

    case check_permission(permissions, permission) do
      :ok -> true
      :denegated -> false
    end
  end

  @doc """
  Checkea si el conjunto de permisos posee el permiso indicado.
  """
  @spec check_permission(Enum.t(), String.t()) :: atom()
  def check_permission(permissions, permission) do
    if Enum.member?(permissions, "any") || Enum.member?(permissions, permission) do
      :ok
    else
      :denegated
    end
  end

  @doc """
  Devuelve la lista de permisos que posee un usuario basado en sus roles.
  """
  @spec extract_permissions(Embers.Accounts.User.t()) :: [String.t()]
  def extract_permissions(user) do
    user.id
    |> Roles.roles_for()
    |> Enum.reduce([], fn x, acc -> Enum.concat(acc, x.permissions) end)
    |> Enum.uniq()
  end

  @doc """
  Devuelve si el usuario es propietario del recurso. Es útil, por ejemplo,
  a la hora de checkear si el usuario puede eliminar un post.
  Si no es moderador, no tendría permisos para hacerlo, pero como el post
  es de su propiedad en realidad sí puede eliminarlo.
  """
  def is_owner?(%User{} = user, %{user_id: user_id} = _resource) do
    user.id == user_id
  end

  def is_owner?(_, _), do: false
end
