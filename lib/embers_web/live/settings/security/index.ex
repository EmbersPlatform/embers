defmodule EmbersWeb.Settings.SecurityLive.Index do
  @moduledoc false
  use EmbersWeb, :live_view

  alias Embers.Accounts
  alias Embers.Accounts.Sessions
  alias EmbersWeb.MountHelpers

  @user_agent_icons %{
    "Chrome" => "/img/user-agents/chrome.png",
    "Chrome Mobile" => "/img/user-agents/chrome.png",
    "Firefox" => "/img/user-agents/firefox.png",
    "Safari" => "/img/user-agents/safari.png",
    "Microsoft Edge" => "/img/user-agents/edge.png",
    "Internet Explorer" => "/img/user-agents/internet-explorer.png",
    "Opera" => "/img/user-agents/opera.png"
  }

  ##################################################
  ## Initialization

  # region [Initialization]

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> MountHelpers.assign_defaults(params, session)
      |> assign_tokens()
      |> assign(:ua_icons, @user_agent_icons)
      |> assign(:sidebar, :security)

    Accounts.subscribe_to_events()

    {:ok, socket}
  end

  # endregion [Initialization]

  ##################################################
  ## HELPERS

  # region [helpers]

  defp assign_tokens(socket) do
    tokens = Sessions.list_sessions(socket.assigns.current_user)

    sessions = Enum.map(tokens, &token_to_session/1) |> sort_sessions

    assign(socket, :sessions, sessions)
  end

  defp token_to_session(%{metadata: %{"user_agent" => user_agent}} = token) do
    ua = UAInspector.parse_client(user_agent)

    %{
      id: token.id,
      token: Base.url_encode64(token.token),
      ua_name: ua.client.name,
      ua_device: ua.device.type,
      ua_os: ua.os_family,
      date: token.inserted_at
    }
  end

  defp token_to_session(token) do
    %{
      id: token.id,
      token: Base.url_encode64(token.token),
      ua_name: gettext("unknown"),
      ua_device: gettext("unknown"),
      ua_os: gettext("unknown"),
      date: token.inserted_at
    }
  end

  defp delete_session(token) do
    case Base.url_decode64(token) do
      {:ok, decoded_token} ->
        Embers.Accounts.delete_session_token(decoded_token)

        live_socket_id = "users_sessions:#{token}"
        EmbersWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end
  end

  defp sort_sessions(sessions) do
    Enum.sort_by(sessions, & &1.id, :desc)
  end

  defp device_icon("smartphone"), do: svg_image("icons/mobile-phone")
  defp device_icon(_), do: svg_image("icons/desktop-pc")

  # endregion [helpers]

  ##################################################
  ## ROUTER

  # region [router]

  @impl true
  def handle_event("confirm_delete", %{"token" => token}, socket) do
    delete_session(token)

    {:noreply, socket}
  end

  def handle_event("close_all", _, socket) do
    IO.inspect(socket, label: "================== CLOSE ALL ===============")

    socket.assigns.sessions
    |> Enum.reject(fn session -> session.token == socket.assigns.session_token end)
    |> Enum.each(fn session -> delete_session(session.token) end)

    {:noreply, socket}
  end

  @impl true
  @spec handle_info({:session, :created | :deleted, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:session, :deleted, token}, socket) do
    sessions =
      socket.assigns.sessions
      |> Enum.reject(fn session -> session.token == Base.url_encode64(token) end)
      |> sort_sessions

    socket = assign(socket, :sessions, sessions)

    {:noreply, socket}
  end

  def handle_info({:session, :created, token}, socket) do
    sessions = [token_to_session(token.token) | socket.assigns.sessions]

    socket = assign(socket, :sessions, sessions |> sort_sessions)

    {:noreply, socket}
  end

  # endregion [router]
end
