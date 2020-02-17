defmodule EmbersWeb.SettingView do
  @moduledoc false

  use EmbersWeb, :view
  alias EmbersWeb.SettingView

  def render("index.json", %{user_settings: user_settings}) do
    %{data: render_many(user_settings, SettingView, "settings.json")}
  end

  def render("show.json", %{settings: settings}) do
    render_one(settings, SettingView, "settings.json")
  end

  def render("settings.json", %{settings: settings}) do
    %{
      content_lowres_images: settings.content_lowres_images,
      content_nsfw: settings.content_nsfw,
      privacy_show_reactions: settings.privacy_show_reactions,
      privacy_show_status: settings.privacy_show_status
    }
  end
end
