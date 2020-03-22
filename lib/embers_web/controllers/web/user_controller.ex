defmodule EmbersWeb.Web.UserController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Accounts.User
  alias Embers.Feed
  alias Embers.Profile.Meta
  alias Embers.Subscriptions

  action_fallback(EmbersWeb.FallbackController)

  def show(conn, %{"username" => username}) do
    with %User{} = user <- Accounts.get_populated(username) do
      %{entries: followers} = Subscriptions.list_following_paginated(user.id, limit: 10)
      activities = Feed.User.get(user_id: user.id)
      followers = subs_to_user(followers)
      render(conn, "show.html", user: user, followers: followers, activities: activities)
    end
  end

  defp subs_to_user(subs) do
    Enum.map(subs, fn sub ->
      user = sub.user
      update_in(user.meta, &Meta.load_avatar_map/1)
    end)
  end
end
