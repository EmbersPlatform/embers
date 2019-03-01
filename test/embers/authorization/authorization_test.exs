defmodule Embers.AuthorizationTest do
  use Embers.DataCase

  alias Embers.Authorization
  alias Embers.Authorization.Roles
  import Embers.Fixtures

  test "returns `:ok` on user with `everyone` permission" do
    user = fixture(:admin)
    assert :ok == Authorization.permit("random_permission", user)
  end

  test "returns :ok on valid permission and :denegated on invalid one" do
    user = fixture(:user)
    role = fixture(:role, ["create_post", "create_media"])
    Roles.attach_role(role.id, user.id)

    assert :ok == Authorization.permit("create_post", user)
    assert :denegated == Authorization.permit("invalid_perm", user)
  end

  test "returns permissions list" do
    permissions = ["permission_1", "permission_2", "permission_3"]
    role = fixture(:role, permissions)
    user = fixture(:user)
    Roles.attach_role(role.id, user.id)

    assert permissions == Authorization.extract_permissions(user)
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
    assert :ok == Authorization.check_permission(["everyone"], "invalid_permission")
  end
end
