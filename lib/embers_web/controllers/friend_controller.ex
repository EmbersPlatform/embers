defmodule EmbersWeb.FriendController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Feed.Subscriptions

  action_fallback(EmbersWeb.FallbackController)

  def list(conn, %{"user_id" => user_id} = params) do
    user_id = IdHasher.decode(user_id)

    friends = Subscriptions.list_friends(user_id, params)

    render(conn, "friends.json", friends)
  end

  def list_ids(conn, %{"user_id" => user_id} = params) do
    user_id = IdHasher.decode(user_id)

    friends_ids = Subscriptions.list_friends_ids(user_id, params)

    render(conn, "friends_ids.json", friends_ids)
  end
end
