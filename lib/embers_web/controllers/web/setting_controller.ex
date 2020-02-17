defmodule EmbersWeb.SettingController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Profile.Settings

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    settings = Settings.get_setting!(user.id)

    with {:ok, settings} <- Settings.update_setting(settings, params) do
      render(conn, "settings.json", settings: settings)
    end
  end
end
