defmodule Embers.Media.MediaItem do
  use Ecto.Schema

  import Ecto.Changeset

  @valid_types ~w(image gif video link)

  schema "media_items" do
    field(:url, :string, null: false)
    field(:type, :string, null: false)
    field(:temporary, :boolean, default: true)
    field(:metadata, {:map, :any})

    belongs_to(:user, Embers.Accounts.User)

    many_to_many(:post, Embers.Feed.Post, join_through: "posts_medias")

    timestamps()
    field(:deleted_at, :naive_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:url, :type, :temporary, :user_id, :metadata])
    |> validate_required([:url, :type, :user_id])
    |> validate_inclusion(
      :type,
      @valid_types,
      message: "is not a valid media type, use one of: #{Enum.join(@valid_types, " ")}"
    )
  end
end
