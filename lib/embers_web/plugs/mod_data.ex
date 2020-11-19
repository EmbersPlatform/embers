defmodule EmbersWeb.Plugs.ModData do
  import Plug.Conn

  alias Embers.Authorization

  def init(default), do: default

  def call(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _options
      )
      when not is_nil(current_user) do
    if Authorization.can?("access_mod_tools", current_user) do
      put_mod_data(conn)
    else
      conn
    end
  end

  def call(conn, _options), do: conn

  defp put_mod_data(conn) do
    pending_reports = Embers.Reports.count_unresolved_reports()

    mod_data =
      %{}
      |> Map.put(:pending_reports_count, pending_reports)

    conn
    |> assign(:mod, mod_data)
  end
end
