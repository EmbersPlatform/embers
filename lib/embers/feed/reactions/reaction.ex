defmodule Embers.Feed.Reactions.Reaction do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Embers.Feed.Subscriptions.Blocks
  alias Embers.Repo

  @valid_reactions ~w(thumbsup thumbsdown grin cry open_mouth angry heart eggplant fire thinking cookie point_up)

  schema "reactions" do
    field(:name, :string, null: false)
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:post, Embers.Feed.Post)

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
    case Repo.get(Embers.Feed.Post, post_id) do
      nil ->
        changeset
        |> Ecto.Changeset.add_error(:parent, "post does not exist")

      post ->
        changeset
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
end
