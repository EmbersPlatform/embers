defmodule Embers.Feed.Activity do
	use Ecto.Schema
	import Ecto.Changeset

	schema "feed_activity" do
		belongs_to :user, Embers.Accounts.User
		belongs_to :post, Embers.Feed.Post
	end

	@doc false
	def changeset(activity, attrs) do
		activity
		|> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
	end
end