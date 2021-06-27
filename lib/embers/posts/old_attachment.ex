defmodule Embers.Posts.OldAttachment do
  @moduledoc """
  This embedded schema is used for backwards compatibility with legacy versions
  of embers.
  """
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:url, :string, null: false)
    field(:meta, :map)
    field(:type, :string, null: false)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:url, :meta, :type])
  end
end
