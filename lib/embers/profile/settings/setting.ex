defmodule Embers.Profile.Settings.Setting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @allowed_themes ["dark", "light"]

  schema "user_settings" do
    field(:content_nsfw, :string, default: "hide")
    field(:content_lowres_images, :boolean, default: false)
    field(:content_collapse_media, :boolean, default: true)

    field(:privacy_show_status, :boolean, default: true)
    field(:privacy_show_reactions, :boolean, default: true)
    field(:privacy_trust_level, :string, default: "everyone")

    field(:style_theme, :string, default: "dark")

    belongs_to(:user, Embers.Accounts.User)

    timestamps()
  end

  def changeset(%Setting{} = setting, attrs) do
    setting
    |> cast(attrs, [
      :user_id,
      :content_nsfw,
      :content_lowres_images,
      :content_collapse_media,
      :privacy_show_status,
      :privacy_show_reactions,
      :privacy_trust_level,
      :style_theme
    ])
    |> validate_required([:user_id])
    |> validate_inclusion(:style_theme, @allowed_themes)
  end

  def update_changeset(%Setting{} = setting, attrs) do
    setting
    |> cast(attrs, [
      :content_nsfw,
      :content_lowres_images,
      :content_collapse_media,
      :privacy_show_status,
      :privacy_show_reactions,
      :privacy_trust_level,
      :style_theme
    ])
    |> validate_inclusion(:style_theme, @allowed_themes)
  end
end
