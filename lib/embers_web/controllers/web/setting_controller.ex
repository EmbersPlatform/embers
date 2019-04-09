defmodule EmbersWeb.SettingController do
  use EmbersWeb, :controller

  alias Embers.Profile.{Settings, Settings.Setting}

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    settings = Settings.get_setting!(user.id)

    with {:ok, %Setting{} = settings} <- Settings.update_setting(settings, params) do
      render(conn, "settings.json", settings: settings)
    end
  end
end
