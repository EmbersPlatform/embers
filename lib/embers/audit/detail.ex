defmodule Embers.AuditDetail do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:action, :string)
    field(:description, :string)
  end

  def changeset(detail, attrs) do
    detail
    |> cast(attrs, [:action, :description])
  end
end
