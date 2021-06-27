defmodule Embers.Settings.Setting do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "settings" do
    field(:name, :string, null: false)
    field(:string_value, :string)
    field(:int_value, :integer, default: 0)

    timestamps()
  end

  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:name, :string_value, :int_value])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
