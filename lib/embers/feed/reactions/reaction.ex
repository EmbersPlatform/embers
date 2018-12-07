defmodule Embers.Feed.Reactions.Reaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Embers.Repo

  @valid_reactions ~w(thumbsup thumbsdown grin cry open_mouth angry heart eggplant fire)

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
    |> validate_reaction(attrs)
    |> validate_post(attrs)
  end

  def validate_reaction(changeset, attrs) do
    case Enum.member?(@valid_reactions, attrs["name"]) do
      true ->
        changeset

      false ->
        changeset
        |> add_error(
          :invalid_reaction,
          "The given reaction is invalid, use one of: #{Enum.join(@valid_reactions, " ")}"
        )
    end
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
    is_blocked? =
      from(
        b in Embers.Feed.Subscriptions.UserBlock,
        where: b.source_id == ^user_id,
        where: b.user_id == ^post.user_id
      )
      |> Repo.exists?()

    if is_blocked? do
      changeset
      |> Ecto.Changeset.add_error(:blocked, "post owner has blocked the user")
    else
      changeset
    end
  end
end
