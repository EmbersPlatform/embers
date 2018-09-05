defmodule Embers.Feed.Post do
  @moduledoc """
  The Posts entity schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    belongs_to :user, Embers.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id])
    |> validate_required([:body, :user_id])
  end
end
