defmodule Embers.Links.EmbedSchema do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:type, :string, null: false)
    field(:url, :string, null: false)
    field(:title, :string)
    field(:description, :string)
    field(:price, :string)
    field(:width, :integer)
    field(:height, :integer)
    field(:html, :string)
    field(:thumbnail_url, :string)
    field(:thumbnail_width, :integer)
    field(:thumbnail_height, :integer)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :type,
      :title,
      :url,
      :description,
      :price,
      :width,
      :height,
      :html,
      :thumbnail_url,
      :thumbnail_width,
      :thumbnail_height
    ])
    |> validate_required([:type, :url])
  end
end
