defmodule EmbersWeb.Api.FriendView do
  @moduledoc false

  use EmbersWeb, :view

  alias EmbersWeb.Api.UserView

  def render("friends.json", %{entries: friends} = metadata) do
    %{
      items: render_many(friends, __MODULE__, "friend.json"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("friends_ids.json", %{entries: ids} = metadata) do
    %{
      ids: render_many(ids, __MODULE__, "friend_id"),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("friend_id", %{friend: id}) do
    id
  end

  def render("friend.json", %{friend: friend}) do
    render_one(friend.user, UserView, "user.json")
  end
end
