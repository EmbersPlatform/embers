defmodule Embers.Tags.Tag do
  @moduledoc """
  Tags schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  @max_length 100

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "tags" do
    field(:name, :string, null: false)
    field(:description, :string)

    many_to_many(:posts, Embers.Posts.Post, join_through: "tags_posts")
  end

  def changeset(changeset, attrs), do: create_changeset(changeset, attrs)

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name, :description])
    |> validate_required(:name)
    |> validate_length(:name, min: 2, max: @max_length)
    |> validate_format(:name, ~r/^\w+$/u)
    |> trim_desc(attrs)
  end

  def valid_name?(name) do
    Regex.match?(~r/^\w+$/, name)
  end

  defp trim_desc(changeset, %{"description" => body} = _attrs) when not is_nil(body) do
    changeset
    |> change(description: String.trim(body))
  end

  defp trim_desc(changeset, _), do: changeset

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:id, :name, :description]), opts)
    end
  end
end
