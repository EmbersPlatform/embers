defmodule Embers.Factory do
  use ExMachina.Ecto, repo: Embers.Repo

  def user_factory do
    name = sequence(:username, &"user_#{&1}")

    %Embers.Accounts.User{
      username: name,
      canonical: name,
      email: sequence(:email, &"user_#{&1}@example.com"),
      password_hash: Pbkdf2.hash_pwd_salt("yayapapaya")
    }
  end

  def role_factory(%{permissions: permissions} = _attrs) do
    %Embers.Authorization.Role{
      name: sequence(:rolename, &"role_#{&1}"),
      permissions: permissions
    }
  end
end
