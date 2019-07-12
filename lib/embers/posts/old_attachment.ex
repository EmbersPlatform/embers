defmodule Embers.Posts.OldAttachment do
  @moduledoc """
  Este es un esquema embebido usado sólo para los posts del backend viejo.
  Antes no existía el concepto de medio, sino de "attachments" que se guardaban
  en la misma tabla del post.
  Como hay muchas urls que son incompatibles con este backend, es preferible
  esto para mantener la retrocompatibilidad con `fenix`.
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
