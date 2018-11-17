defmodule Embers.Media.MediaItem do
  use Ecto.Schema

  import Ecto.Changeset

  schema "media_items" do
    field(:url, :string, null: false)
    field(:filename, :string)
    field(:original_filename, :string)
    field(:temporary, :boolean, default: true)

    belongs_to(:user, Embers.Accounts.User)

    many_to_many(:post, Embers.Feed.Post, join_through: "posts_medias")

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:url, :filename, :original_filename, :temporary, :user_id])
    |> validate_required([:url, :user_id])
  end
end
