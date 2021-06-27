defmodule Embers.Fixtures do
  alias Embers.Authorization.Roles
  import Embers.Factory

  def fixture(:admin) do
    user = insert(:user)
    role = insert(:role, %{permissions: ["any"]})
    Roles.attach_role(role.id, user.id)
    user
  end
end
