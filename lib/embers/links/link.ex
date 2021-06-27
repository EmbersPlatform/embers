defmodule Embers.Links.Link do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "links" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    field(:url, :string, null: false)
    embeds_one(:embed, Embers.Links.EmbedSchema)
    field(:temporary, :boolean, default: true)

    many_to_many(:posts, Embers.Posts.Post, join_through: "link_post")

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:user_id])
    |> foreign_key_constraint(:link_post)
    |> put_change(:embed, attrs.embed)
    |> change(url: attrs.embed.url)
    |> validate_required([:user_id, :embed, :url])
  end
end
