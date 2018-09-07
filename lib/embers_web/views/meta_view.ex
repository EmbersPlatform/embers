defmodule EmbersWeb.MetaView do
  use EmbersWeb, :view
  alias EmbersWeb.MetaView

  def render("index.json", %{user_metas: user_metas}) do
    %{data: render_many(user_metas, MetaView, "meta.json")}
  end

  def render("show.json", %{meta: meta}) do
    render_one(meta, MetaView, "meta.json")
  end

  def render("meta.json", %{meta: meta}) do
    meta = meta |> Embers.Profile.Meta.load_avatar_map()
    %{id: meta.id, bio: meta.bio, avatar: meta.avatar, cover: meta.cover_name}
  end

  def render("avatar.json", %{avatar: avatar}) do
    %{
      small: avatar.small,
      medium: avatar.medium,
      big: avatar.big
    }
  end
end
