defmodule EmbersWeb.MountHelpers do
  import Phoenix.LiveView
  alias Embers.Accounts
  alias Embers.Authorization
  alias Embers.Profile.Settings

  alias EmbersWeb.Router.Helpers, as: Routes

  @doc """
  Assign default values on the socket.
  """
  def assign_defaults(socket, _params, session) do
    IO.inspect(session, label: "========== SESSION")

    socket
    |> assign_locale(session)
    |> assign_current_user(session)
    |> ensure_authenticated()
  end

  @doc """
  Assign default values for users that may or may not be logged in.
  """
  def assign_maybe_logged_in_defaults(socket, user_token) do
    socket
    |> assign_new(:current_user, fn ->
      user_token && Accounts.get_user_by_session_token(user_token)
    end)
    |> assign(:session_token, Base.url_encode64(user_token))
  end

  # region [helpers]

  defp assign_locale(socket, %{"locale" => locale}) do
    IO.inspect(locale, label: "============ LOCALE")
    Gettext.put_locale(EmbersWeb.Gettext, locale)

    socket
  end

  defp assign_locale(socket, _session), do: socket

  defp assign_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(session["user_token"])
    end)
    |> assign(:session_token, Base.url_encode64(session["user_token"]))
  end

  defp assign_permissions(socket = %{assigns: %{current_user: user}}) do
    user = put_in(user.permissions, Authorization.extract_permissions(user))
    assign(socket, :current_user, user)
  end

  defp assign_permissions(socket), do: socket

  defp assign_settings(socket = %{assigns: %{current_user: user}}) do
    user = put_in(user.settings, Settings.get_setting!(user.id))
    assign(socket, :current_user, user)
  end

  defp assign_settings(socket), do: socket

  defp assign_mod_data(socket = %{assigns: %{current_user: user}}) do
    if Authorization.can?("access_mod_tools", user) do
      pending_reports = Embers.Reports.count_unresolved_reports()

      mod_data =
        %{}
        |> Map.put(:pending_reports_count, pending_reports)

      assign_new(socket, :mod, fn -> mod_data end)
    else
      socket
    end
  end

  defp assign_mod_data(socket), do: socket

  defp ensure_authenticated(socket) do
    case socket.assigns.current_user do
      %Embers.Accounts.User{} ->
        socket
        |> assign_permissions()
        |> assign_settings()
        |> assign_mod_data()

      _other ->
        socket
        |> put_flash(:error, "You must log in to access this page.")
        |> push_redirect(to: Routes.user_session_path(socket, :new))
    end
  end

  # endregion [helpers]
end
