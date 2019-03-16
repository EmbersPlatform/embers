defmodule Embers.AuthorizationTest do
  use Embers.DataCase

  alias Embers.Authorization
  alias Embers.Authorization.Roles
  import Embers.Fixtures

  test "returns true on user with `any` permission" do
    user = fixture(:admin)
    assert Authorization.can?("random_permission", user)
  end

  test "returns true on valid permission and :denegated on invalid one" do
    user = fixture(:user)
    role = fixture(:role, ["create_post", "create_media"])
    Roles.attach_role(role.id, user.id)

    assert Authorization.can?("create_post", user)
    refute Authorization.can?("invalid_perm", user)
  end

  test "returns permissions list" do
    role = fixture(:role, ~w(permission1 permission2 permission3))
    user = fixture(:user)
    Roles.attach_role(role.id, user.id)

    Enum.each(role.permissions, fn permission ->
      assert Enum.member?(Authorization.extract_permissions(user), permission)
    end)
  end

  test "checks ownership" do
    user = fixture(:user)
    valid_resource = %{user_id: user.id}
    invalid_resource = %{user_id: user.id + 1}

    assert true == Authorization.is_owner?(user, valid_resource)
    assert false == Authorization.is_owner?(user, invalid_resource)
    assert false == Authorization.is_owner?(user, %{})
  end

  test "checks permission" do
    permissions = ["permission1", "permission2"]

    assert :ok == Authorization.check_permission(permissions, "permission1")
    assert :ok == Authorization.check_permission(permissions, "permission2")
    assert :denegated == Authorization.check_permission(permissions, "invalid_permission")
    assert :ok == Authorization.check_permission(["any"], "invalid_permission")
  end
end
