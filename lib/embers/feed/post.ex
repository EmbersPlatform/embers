defmodule Embers.Feed.Post do
  @moduledoc """
  The Posts entity schema
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias __MODULE__
  alias Embers.Repo

  @max_body_len 1600

  schema "posts" do
    field(:body, :string)
    field(:nesting_level, :integer, default: 0)
    field(:replies_count, :integer, default: 0)
    field(:shares_count, :integer, default: 0)
    field(:my_reactions, {:array, :string}, virtual: true)
    field(:mentions, {:array, :string}, virtual: true)

    belongs_to(:user, Embers.Accounts.User)

    # A post may be in reply to another post
    # Comments no longer have their own entity as they had in fenix
    belongs_to(:parent, Embers.Feed.Post)
    belongs_to(:related_to, Embers.Feed.Post)
    has_many(:replies, Embers.Feed.Post)
    has_many(:reactions, Embers.Feed.Reactions.Reaction)

    many_to_many(:media, Embers.Media.MediaItem, join_through: "posts_medias")
    field(:old_attachment, {:map, :any})

    many_to_many(:tags, Embers.Tags.Tag, join_through: "tags_posts")

    field(:deleted_at, :naive_datetime)
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :parent_id, :related_to_id])
    |> validate_required([:user_id])
    |> trim_body(attrs)
    |> validate_body(attrs)
    |> validate_related_to(attrs)
    |> validate_parent_and_set_nesting_level(attrs)
    |> validate_number(:nesting_level, less_than_or_equal_to: 2)
  end

  def bulk_changeset(post, attrs) do
    post
    |> cast(attrs, [:id, :body, :user_id, :parent_id, :related_to_id])
    |> trim_body(attrs)
    |> validate_required([:user_id])
    |> validate_related_to(attrs)
    |> validate_parent_and_set_nesting_level(attrs)
    |> validate_number(:nesting_level, less_than_or_equal_to: 2)
    |> cast_embed(:old_attachment)
  end

  defp validate_body(changeset, _attrs) do
    changeset
    |> validate_length(:body, max: @max_body_len)
  end

  defp trim_body(changeset, %{"body" => body} = _attrs) when not is_nil(body) do
    changeset
    |> change(body: String.trim(body))
  end

  defp trim_body(changeset, _), do: changeset

  defp validate_parent_and_set_nesting_level(changeset, %{"parent_id" => parent_id}) do
    case Repo.get(Post, parent_id) do
      nil ->
        changeset
        |> Ecto.Changeset.add_error(:parent, "parent post does not exist")

      parent ->
        changeset
        |> check_if_can_reply(parent)
        |> set_nesting_level(parent.nesting_level)
    end
  end

  defp validate_parent_and_set_nesting_level(changeset, _) do
    changeset
  end

  defp set_nesting_level(changeset, parent_nesting_level) do
    if(parent_nesting_level < 2) do
      changeset
      |> change(nesting_level: parent_nesting_level + 1)
    else
      changeset
      |> add_error(:nesting_level, "max nesting level is 2")
    end
  end

  defp check_if_can_reply(changeset, parent) do
    user_id = get_change(changeset, :user_id)

    is_blocked? =
      from(
        b in Embers.Feed.Subscriptions.UserBlock,
        where: b.source_id == ^user_id,
        where: b.user_id == ^parent.user_id
      )
      |> Repo.exists?()

    if is_blocked? do
      changeset
      |> Ecto.Changeset.add_error(:blocked, "parent post owner has blocked the post creator")
    else
      changeset
    end
  end

  defp validate_related_to(changeset, attrs) do
    parent_id = attrs["parent_id"]
    related_to_id = attrs["related_to_id"]

    if not is_nil(parent_id) and not is_nil(related_to_id) do
      Ecto.Changeset.add_error(
        changeset,
        :invalid_data,
        "only one of `parent_id` and `related_to` can be present at the same time"
      )
    else
      changeset
    end
    |> assoc_constraint(:related_to)
  end
end
