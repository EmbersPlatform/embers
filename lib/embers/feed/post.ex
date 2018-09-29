defmodule Embers.Feed.Post do
  @moduledoc """
  The Posts entity schema
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Embers.Repo

  schema "posts" do
    field(:body, :string)
    field(:nesting_level, :integer, default: 0)

    belongs_to(:user, Embers.Accounts.User)

    # A post may be in reply to another post
    # Comments no longer have their own entity as they had in fenix
    belongs_to(:parent, Embers.Feed.Post)
    has_many(:replies, Embers.Feed.Post)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :parent_id])
    |> validate_required([:body, :user_id])
    |> validate_parent_and_set_nesting_level(attrs)
    |> validate_number(:nesting_level, less_than_or_equal_to: 2)
  end

  defp validate_parent_and_set_nesting_level(changeset, %{"parent_id" => parent_id}) do
    case Repo.get(Post, parent_id) do
      nil ->
        changeset
        |> Ecto.Changeset.add_error(:parent, "parent post does not exist")

      parent ->
        changeset
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
      |> Ecto.Changeset.add_error(:nesting_level, "max nesting level is 2")
    end
  end
end
