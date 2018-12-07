defmodule Embers.Tags.Tag do
  use Ecto.Schema

  import Ecto.Changeset

  @max_length 20

  schema "tags" do
    field(:name, :string, null: false)

    many_to_many(:posts, Embers.Feed.Post, join_through: "tags_posts")
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name])
    |> validate_required(:name)
    |> validate_length(:name, min: 2, max: @max_length)
    |> validate_format(:name, ~r/^\w+$/)
  end
end
