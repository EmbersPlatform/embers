defmodule Embers.AccountsTest do
  use Embers.DataCase

  alias Embers.Accounts
  alias Embers.Accounts.User

  import Embers.Fixtures
  import Embers.Factory

  @user_attrs %{
    username: "Test",
    email: "test@example.com",
    password: "testpassword1"
  }

  test "list_users_paginated/1 returns a Page of results" do
    page = Accounts.list_users_paginated()

    assert %Embers.Paginator.Page{} = page
  end

  test "get_user/1 returns a user by it's id" do
    user = insert(:user)

    assert user == Accounts.get_user(user.id)
  end

  test "get_by_identifier/1 returns the user by id or canonical" do
    user = insert(:user)

    assert user == Accounts.get_by_identifier(user.canonical)
    assert user == Accounts.get_by_identifier(user.id)
  end

  test "get_populated/2 returns the user with it's Meta and Settings" do
    user = insert(:user)

    retrieved_user = Accounts.get_populated(user.id)

    assert user.id == retrieved_user.id
    assert %Embers.Profile.Meta{} = retrieved_user.meta
    assert %Embers.Settings.Setting{} = retrieved_user.settings
  end

  test "create_user/2 creates a user with valid attributes" do
    insert(:role, %{"name" => "member"})

    assert {:ok, %User{}} = Accounts.create_user(@user_attrs)
  end
end
