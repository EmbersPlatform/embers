defmodule Embers.Feed.Favorite do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "favorites" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:post, Embers.Feed.Post)

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
