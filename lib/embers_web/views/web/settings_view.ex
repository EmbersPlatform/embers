defmodule EmbersWeb.Web.SettingsView do
  @moduledoc false

  use EmbersWeb, :view

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

  def render("profile.json", %{meta: meta}) do
    %{
      bio: meta.bio
    }
  end

  def render("settings.json", %{settings: settings}) do
    %{
      content_nsfw: settings.content_nsfw,
      content_lowres_images: settings.content_lowres_images,
      content_collapse_media: settings.content_collapse_media,
      privacy_show_status: settings.privacy_show_status,
      privacy_show_reactions: settings.privacy_show_reactions,
      privacy_trust_level: settings.privacy_trust_level,
      style_theme: settings.style_theme
    }
  end
end
