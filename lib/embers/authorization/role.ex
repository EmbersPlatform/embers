defmodule Embers.Authorization.Role do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "roles" do
    field(:name, :string, null: false)
    field(:permissions, {:array, :string})
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name, :permissions])
  end
end
