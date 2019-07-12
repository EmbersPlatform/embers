defmodule Embers.Tags.TagPost do
  @moduledoc """
  El esquema de la relacion entre los tags y los posts
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "tags_posts" do
    belongs_to(:tag, Embers.Tags.Tag)
    belongs_to(:post, Embers.Posts.Post)

    timestamps()
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:tag_id, :post_id])
    |> validate_required([:tag_id, :post_id])
  end
end
