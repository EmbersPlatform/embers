defmodule EmbersWeb.Web.UserController do
  @moduledoc false
  use EmbersWeb, :controller

  import Ecto.Query
  alias Embers.Repo

  alias Embers.Accounts
  alias Embers.Accounts.User
  alias Embers.Feed

  alias Embers.Profile.Meta
  alias Embers.Subscriptions

  action_fallback(EmbersWeb.FallbackController)

  def show(conn, %{"username" => username}) do
    with user <- Accounts.get_populated(%{"canonical" => username}) do
      current_user = conn.assigns.current_user
      %{entries: followers} = Subscriptions.list_following_paginated(user.id, limit: 10)
      activities = Feed.User.get(user_id: user.id)
      followers = subs_to_user(followers)

      user =
        user
        |> Accounts.load_following_status(current_user.id)
        |> Accounts.load_follows_me_status(current_user.id)
        |> Accounts.load_blocked_status(current_user.id)

      title = gettext("@%{username}'s profile", username: user.username)
      render(conn, "show.html", page_title: title, user: user, followers: followers, activities: activities)
    end
  end

  def timeline(conn, %{"user_id" => user_id} = params) do
    posts =
      Feed.User.get(
        user_id: user_id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    conn
    |> put_layout(false)
    |> Embers.Paginator.put_page_headers(posts)
    |> render("timeline.html", posts: posts)
  end

  def show_followers(conn, %{"username" => canonical} = params) do
    with user <- Accounts.get_populated(%{"canonical" => canonical}) do
      followers =
        Subscriptions.list_followers_paginated(user.id,
          after: params["after"],
          before: params["before"],
          limit: params["limit"]
        )
        |> maybe_load_follows_me_status(conn)
        |> maybe_load_following_status(conn)
        |> Embers.Paginator.map(&(&1.user))


      if params["entries"] == "true" do
        conn
        |> put_layout(false)
        |> Embers.Paginator.put_page_headers(followers)
        |> render("followers_items.html", user: user, users: followers)
      else
        conn
        |> Embers.Paginator.put_page_headers(followers)
        |> render("followers.html", user: user, users: followers)
      end
    end
  end

  def show_following(conn, %{"username" => canonical} = params) do
    with user <- Accounts.get_populated(%{"canonical" => canonical}) do
      following =
        Subscriptions.list_following_paginated(user.id,
          after: params["after"],
          before: params["before"],
          limit: params["limit"]
        )
        |> maybe_load_follows_me_status(conn, :source_id)
        |> maybe_load_following_status(conn, :source_id)
        |> Embers.Paginator.map(&(&1.user))


      if params["entries"] == "true" do
        conn
        |> put_layout(false)
        |> Embers.Paginator.put_page_headers(following)
        |> render("following_items.html", user: user, users: following)
      else
        conn
        |> Embers.Paginator.put_page_headers(following)
        |> render("following.html", user: user, users: following)
      end
    end
  end

  defp maybe_load_following_status(page, conn, id_field \\ :user_id) do
    if is_nil(conn.assigns.current_user) do
      page
    else
      ids = get_following_ids(page.entries, conn, id_field)
      Embers.Paginator.map(page, fn sub ->
        if sub.user.id in ids do
          put_in(sub.user.following, true)
        else
          sub
        end
      end)
    end
  end

  defp maybe_load_follows_me_status(page, conn, id_field \\ :user_id) do
    if is_nil(conn.assigns.current_user) do
      page
    else
      ids = get_followers_ids(page.entries, conn, id_field)
      Embers.Paginator.map(page, fn sub ->
        if sub.user.id in ids do
          put_in(sub.user.follows_me, true)
        else
          sub
        end
      end)
    end
  end

  #
  # TODO Move all this to a context as we should not use Ecto from a controller
  #
  defp get_followers_ids(subs, conn, id_field) do
    user_ids = Enum.map(subs, &(Map.get(&1, id_field)))
    from(
      sub in Embers.Subscriptions.UserSubscription,
      where: sub.source_id == ^conn.assigns.current_user.id,
      where: sub.user_id in ^user_ids,
      select: sub.user_id
    ) |> Repo.all()
  end
  defp get_following_ids(subs, conn, id_field) do
    user_ids = Enum.map(subs, &(Map.get(&1, id_field)))
    from(
      sub in Embers.Subscriptions.UserSubscription,
      where: sub.user_id == ^conn.assigns.current_user.id,
      where: sub.source_id in ^user_ids,
      select: sub.source_id
    ) |> Repo.all()
  end

  defp subs_to_user(subs) do
    Enum.map(subs, fn sub ->
      user = sub.user
      update_in(user.meta, &Meta.load_avatar_map/1)
    end)
  end
end
