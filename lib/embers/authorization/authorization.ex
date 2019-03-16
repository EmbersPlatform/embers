defmodule Embers.Authorization do
  alias Embers.Authorization.Roles
  alias Embers.Accounts.User

  @spec can?(String.t(), Embers.Accounts.User.t()) :: boolean()
  def can?(permission, user) do
    permissions = extract_permissions(user)

    case check_permission(permissions, permission) do
      :ok -> true
      :denegated -> false
    end
  end

  @spec check_permission(Enum.t(), String.t()) :: atom()
  def check_permission(permissions, permission) do
    if(Enum.member?(permissions, "any")) do
      :ok
    else
      if(Enum.member?(permissions, permission)) do
        :ok
      else
        :denegated
      end
    end
  end

  @spec extract_permissions(Embers.Accounts.User.t()) :: [String.t()]
  def extract_permissions(user) do
    Roles.roles_for(user.id)
    |> Enum.reduce([], fn x, acc -> Enum.concat(acc, x.permissions) end)
    |> Enum.uniq()
  end

  def is_owner?(%User{} = user, %{user_id: user_id} = _resource) do
    user.id == user_id
  end

  def is_owner?(_, _), do: false
end
