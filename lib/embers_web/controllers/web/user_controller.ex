defmodule EmbersWeb.Web.UserController do
  @moduledoc false
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Accounts.User
  alias Embers.Feed
  alias Embers.Helpers.IdHasher
  alias Embers.Profile.Meta
  alias Embers.Subscriptions

  action_fallback(EmbersWeb.FallbackController)

  def show(conn, %{"username" => username}) do
    with %User{} = user <- Accounts.get_populated(username) do
      %{entries: followers} = Subscriptions.list_following_paginated(user.id, limit: 10)
      activities = Feed.User.get(user_id: user.id)
      followers = subs_to_user(followers)

      title = gettext("@%{username}'s profile", username: user.username)
      render(conn, "show.html", page_title: title, user: user, followers: followers, activities: activities)
    end
  end

  def timeline(conn, %{"user_id" => user_id} = params) do
    posts =
      Feed.User.get(
        user_id: IdHasher.decode(user_id),
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    conn
    |> put_layout(false)
    |> Embers.Paginator.put_page_headers(posts)
    |> render("timeline.html", posts: posts)
  end

  defp subs_to_user(subs) do
    Enum.map(subs, fn sub ->
      user = sub.user
      update_in(user.meta, &Meta.load_avatar_map/1)
    end)
  end
end
