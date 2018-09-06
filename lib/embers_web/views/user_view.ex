defmodule EmbersWeb.UserView do
  use EmbersWeb, :view
  alias EmbersWeb.{UserView, MetaView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    view = %{
      id: user.id,
      username: user.username,
      email: user.email,
      badges: [],
      permissions: []
    }

    view =
      if Ecto.assoc_loaded?(user.meta) do
        Map.put(view, "meta", render_one(user.meta, MetaView, "meta.json"))
      else
        view
      end

    view
  end
end
