defmodule Embers.Authorization do
  @moduledoc """
  Holds utility functions to check if a user is able to perform an action based
  on a set of permissions.
  """
  alias Embers.Accounts.User
  alias Embers.Authorization.Roles

  @type permission :: String.t()
  @type permission_list :: [permission]
  @type status :: :ok | :denegated

  @doc """
  Extracts the permissions from a user and checks if it has a given `permission`.
  Uses `check_permission/2` under the hood.
  """
  @spec can?(User.t(), permission()) :: boolean()
  def can?(%User{} = user, permission), do: can?(permission, user)

  @spec can?(permission, %{permissions: permission_list()}) :: boolean()
  def can?(permission, %{permissions: permissions}) when is_list(permissions) do
    case check_permission(permissions, permission) do
      :ok -> true
      :denegated -> false
    end
  end

  @spec can?(permission(), User.t()) :: boolean()
  def can?(permission, user) do
    permissions = extract_permissions(user)

    case check_permission(permissions, permission) do
      :ok -> true
      :denegated -> false
    end
  end

  @doc """
  Checks if the `permission` is present on the given `permissions`.
  Returns `true` if the `"any"` permission is present.
  """
  @spec check_permission(permission_list(), permission()) :: status()
  def check_permission(permissions, permission) do
    if Enum.member?(permissions, "any") || Enum.member?(permissions, permission) do
      :ok
    else
      :denegated
    end
  end

  @doc """
  Returns the list of permissions associated to a user.

  A user can have many roles, so the list os the result of merging and deduping
  the permissions of it's roles.
  """
  @spec extract_permissions(Embers.Accounts.User.t()) :: permission_list()
  def extract_permissions(user) do
    user
    |> Roles.roles_for()
    |> Enum.reduce([], fn x, acc -> Enum.concat(acc, x.permissions) end)
    |> Enum.uniq()
  end

  @doc """
  Checks if the user is the owner of a resource. This is useful when you want to
  check if the user can delete a post.
  """
  @spec is_owner?(User.t() | any(), %{user_id: integer()} | any()) :: boolean()
  def is_owner?(%User{} = user, %{user_id: user_id} = _resource) do
    user.id == user_id
  end

  def is_owner?(_, _), do: false
end
