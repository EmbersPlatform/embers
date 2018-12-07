defmodule Embers.Tags.TagPost do
  use Ecto.Schema

  import Ecto.Changeset

  schema "tags_posts" do
    belongs_to(:tag, Embers.Tags.Tag)
    belongs_to(:post, Embers.Feed.Post)

    timestamps()
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:tag_id, :post_id])
    |> validate_required([:tag_id, :post_id])
  end
end
