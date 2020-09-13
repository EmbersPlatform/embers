defmodule Embers.Authorization.RoleUser do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Embers.Authorization.Role

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "role_user" do
    belongs_to(:role, Role, type: Embers.Hashid)
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
  end

  def changeset(role_user, attrs) do
    role_user
    |> cast(attrs, [:role_id, :user_id])
    |> validate_required([:role_id, :user_id])
  end
end
