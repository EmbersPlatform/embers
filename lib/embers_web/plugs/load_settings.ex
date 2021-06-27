defmodule EmbersWeb.Plugs.LoadSettings do
  import Plug.Conn
  alias Embers.Profile.Settings

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{current_user: user}} = conn, _default) when not is_nil(user) do
    user = put_in(user.settings, Settings.get_setting!(user.id))
    assign(conn, :current_user, user)
  end

  def call(conn, _default) do
    conn
  end
end
