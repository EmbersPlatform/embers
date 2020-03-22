defmodule EmbersWeb.Api.MetaView do
  @moduledoc false

  use EmbersWeb, :view
  alias EmbersWeb.Api.MetaView
  alias Embers.Profile.Meta

  def render("index.json", %{user_metas: user_metas}) do
    %{data: render_many(user_metas, MetaView, "meta.json")}
  end

  def render("show.json", %{meta: meta}) do
    render_one(meta, MetaView, "meta.json")
  end

  def render("meta.json", %{meta: meta}) do
    meta =
      meta
      |> Meta.load_avatar_map()
      |> Meta.load_cover()

    %{bio: meta.bio, avatar: meta.avatar, cover: meta.cover}
  end

  def render("avatar.json", %{avatar: avatar}) do
    %{
      small: avatar.small,
      medium: avatar.medium,
      big: avatar.big
    }
  end

  def render("cover.json", %{cover: cover}) do
    cover
  end
end
