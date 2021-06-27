defmodule Embers.Favorites.Favorite do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "favorites" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    belongs_to(:post, Embers.Posts.Post, type: Embers.Hashid)

    timestamps()
  end

  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
    |> unique_constraint(:unique_favorite, name: :unique_favorite)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_id)
  end
end
