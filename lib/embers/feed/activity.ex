defmodule Embers.Feed.Activity do
  @moduledoc """
  Activities are used to build each user's feeds.

  Embers uses a fanout method to create feeds/timelines.
  Every time a post is created, the list of users that should receive it is
  generated, and an `Activity` is created for each one of them.

  A feed query for a timeline could be used, but we've hit some problems with
  that approach before:
  - The query gets progressively slower the more followers the user has. Joins
  and where in clauses are expensive, so a simpler query is needed to get a
  timeline *fast*.
  - If a user wants to remove an activity from it's feed, it gets harder if the
  feed is generated only with the posts table, usually involving extra tables.

  Feeds and activities could be thought of as newsletters and subscriptions.
  It's the same idea, actually. You start receving posts from a user from the
  moment you subscribe to it. You can cancel a subscription at any moment, but
  you can keep the posts you've already received.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "feed_activity" do
    belongs_to(:user, Embers.Accounts.User, type: Embers.Hashid)
    belongs_to(:post, Embers.Posts.Post, type: Embers.Hashid)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
  end
end
