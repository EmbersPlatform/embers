defmodule EmbersWeb.MetaView do
  use EmbersWeb, :view
  alias EmbersWeb.MetaView

  def render("index.json", %{user_metas: user_metas}) do
    %{data: render_many(user_metas, MetaView, "meta.json")}
  end

  def render("show.json", %{meta: meta}) do
    %{data: render_one(meta, MetaView, "meta.json")}
  end

  def render("meta.json", %{meta: meta}) do
    %{id: meta.id,
      bio: meta.bio,
      avatar: meta.avatar,
      cover: meta.cover_name}
  end
end
