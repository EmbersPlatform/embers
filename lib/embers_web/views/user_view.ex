defmodule EmbersWeb.UserView do
  @moduledoc false
  use EmbersWeb, :view

  alias EmbersWeb.Api.MetaView

  def render("show.json", %{user: user}) do
    render("user.json", %{user: user})
  end

  def render("user.json", %{user: user} = _assigns) do
    view = %{
      id: user.id,
      username: user.username,
      badges: [],
      canonical: user.canonical,
      stats: %{
        posts: 0,
        followers: 0,
        friends: 0,
        comments: 0
      },
      following: user.following,
      follows_me: user.follows_me,
      blocked: user.blocked
    }

    view =
      if is_nil(user.stats) do
        view
      else
        %{view | stats: user.stats}
      end

    view =
      if Ecto.assoc_loaded?(user.meta) do
        Map.merge(view, render_one(user.meta, MetaView, "meta.json", as: :meta))
      else
        view
      end

    view
  end

  def render("user_with_email.json", %{user: user}) do
    view = render_one(user, __MODULE__, "user.json")
    Map.put(view, :email, user.email)
  end
end
