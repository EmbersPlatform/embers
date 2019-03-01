defmodule Embers.Fixtures do
  alias Embers.{Accounts, Authorization.Roles}

  def fixture(:user) do
    with {:ok, user} <-
           Accounts.create_user(%{
             username: "dorgan",
             password: "yayapapaya",
             email: "mail@mail.com"
           }),
         {:ok, user} <- Accounts.confirm_user(user) do
      user
    else
      error -> error
    end
  end

  def fixture(:admin) do
    user = fixture(:user)
    role = fixture(:role, ["everyone"])
    Roles.attach_role(role.id, user.id)
    user
  end

  def fixture(:role, perms) do
    {:ok, role} = Roles.create("some_role", perms)
    role
  end
end
