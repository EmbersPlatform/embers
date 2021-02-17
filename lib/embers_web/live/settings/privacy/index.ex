defmodule EmbersWeb.Web.Settings.PrivacyLive.Index do
  use EmbersWeb, :live_view

  alias EmbersWeb.MountHelpers

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> MountHelpers.assign_defaults(params, session)
      |> assign(:sidebar, :privacy)

    {:ok, socket}
  end
end
