defmodule EmbersWeb.FriendView do
  @moduledoc false

  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher
  alias EmbersWeb.UserView

  def render("friends.json", %{friends: friends} = _assigns) do
    %{
      items: render_many(friends.entries, __MODULE__, "friend.json"),
      next: friends.next,
      last_page: friends.last_page
    }
  end

  def render("friends_ids.json", %{ids: ids} = _assigns) do
    %{
      ids: render_many(ids.entries, __MODULE__, "friend_id"),
      next: ids.next,
      last_page: ids.last_page
    }
  end

  def render("friend_id", %{friend: id}) do
    IdHasher.encode(id)
  end

  def render("friend.json", %{friend: friend}) do
    render_one(friend.user, UserView, "user.json")
  end
end
