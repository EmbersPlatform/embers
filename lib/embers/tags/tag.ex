defmodule Embers.Tags.Tag do
  @moduledoc """
  El esquema de los tags
  """
  use Ecto.Schema

  import Ecto.Changeset

  @max_length 100

  schema "tags" do
    field(:name, :string, null: false)
    field(:description, :string)

    many_to_many(:posts, Embers.Feed.Post, join_through: "tags_posts")
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name, :description])
    |> validate_required(:name)
    |> validate_length(:name, min: 2, max: @max_length)
    |> validate_format(:name, ~r/^\w+$/)
    |> trim_desc(attrs)
  end

  defp trim_desc(changeset, %{"description" => body} = _attrs) when not is_nil(body) do
    changeset
    |> change(description: String.trim(body))
  end

  defp trim_desc(changeset, _), do: changeset
end
