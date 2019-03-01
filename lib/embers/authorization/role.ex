defmodule Embers.Authorization.Role do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "roles" do
    field(:name, :string, null: false)
    field(:permissions, {:array, :string})
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name, :permissions])
    |> unique_constraint(:unique_role_user, name: :unique_role_user)
  end
end
