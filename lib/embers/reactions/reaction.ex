defmodule Embers.Reactions.Reaction do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Embers.Blocks
  alias Embers.Repo

  @valid_reactions ~w(thumbsup thumbsdown grin cry thinking point_up angry tada heart eggplant hot_pepper cookie fire)

  schema "reactions" do
    field(:name, :string, null: false)
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    belongs_to(:post, Embers.Posts.Post, type: Embers.Hashid)

    timestamps()
  end

  def create_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name, :user_id, :post_id])
    |> unique_constraint(:unique_reaction, name: :unique_reaction)
    |> validate_post(attrs)
    |> validate_inclusion(
      :name,
      @valid_reactions,
      message: "is not a valid reaction, use one of: #{Enum.join(@valid_reactions, " ")}"
    )
  end

  def valid_reactions do
    @valid_reactions
  end

  defp validate_post(changeset, %{"post_id" => post_id} = attrs) do
    case Repo.get(Embers.Posts.Post, post_id) do
      nil ->
        changeset
        |> Ecto.Changeset.add_error(:parent, "post does not exist")

      post ->
        changeset
        |> validate_is_not_owner(post)
        |> check_if_can_react(attrs, post)
    end
  end

  defp check_if_can_react(changeset, %{"user_id" => user_id}, post) do
    if Blocks.blocked?(user_id, post.user_id) do
      changeset
      |> Ecto.Changeset.add_error(:blocked, "post owner has blocked the user")
    else
      changeset
    end
  end

  def validate_is_not_owner(changeset, post) do
    if get_change(changeset, :user_id) == post.user_id do
      Ecto.Changeset.add_error(changeset, :is_owner, "can't react to posts made by the same user")
    else
      changeset
    end
  end
end
