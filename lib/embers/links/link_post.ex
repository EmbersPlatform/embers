defmodule Embers.Links.LinkPost do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "link_post" do
    belongs_to(:post, Embers.Posts.Post)
    belongs_to(:link, Embers.Links.Link)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:post_id, :link_id])
    |> validate_required([:post_id, :link_id])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:link_id)
  end
end
