defmodule EmbersWeb.Web.SettingsController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Accounts
  alias Embers.Profile
  alias Embers.Profile.Settings
  alias EmbersWeb.UserAuth

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check)
  plug(:assign_email_and_password_changesets when action in [:show_account])

  def update_email(conn, params) do
    %{"current_password" => password, "email" => email} = params
    user = conn.assigns.current_user

    with {:ok, applied_user} <- Accounts.apply_user_email(user, password, %{email: email}) do
      Accounts.deliver_update_email_instructions(
        applied_user,
        user.email,
        &Routes.settings_url(conn, :confirm_email, &1)
      )

      conn
      |> json(nil)
    end
  end

  def update_password(conn, params) do
    %{"current_password" => password} = params

    user = conn.assigns.current_user

    password_params = Map.take(params, ~w[password password_confirmation])

    with {:ok, user} <- Accounts.update_user_password(user, password, password_params) do
      conn
      |> UserAuth.log_in(user)
      |> json(nil)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.settings_path(conn, :show_profile))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.settings_path(conn, :show_profile))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

  def show_profile(conn, _params) do
    user = conn.assigns.current_user
    profile = Embers.Profile.get_meta_for(user.id)

    conn
    |> assign(:sidebar, :profile)
    |> render("show_profile.html",
      page_title: "Profile settings",
      user: user,
      profile: profile
    )
  end

  def update_profile(conn, params) do
    user = conn.assigns.current_user
    meta = Profile.get_meta_for!(user.id)

    with {:ok, meta} <- Profile.update_meta(meta, params) do
      render(conn, "profile.json", meta: meta)
    end
  end

  def update_avatar(conn, %{"avatar" => file}) do
    user = conn.assigns.current_user
    meta = Profile.get_meta_for!(user.id)

    with {:ok, meta} <- Profile.update_avatar(meta, file) do
      render(conn, "avatar.json", avatar: meta.avatar)
    end
  end

  def update_cover(conn, %{"cover" => file}) do
    user = conn.assigns.current_user
    meta = Profile.get_meta_for!(user.id)

    with {:ok, meta} <- Profile.update_cover(meta, file) do
      render(conn, "cover.json", cover: meta.cover)
    end
  end

  def show_content(conn, _params) do
    user = conn.assigns.current_user
    settings = Embers.Profile.Settings.get_setting!(user.id)

    conn
    |> assign(:sidebar, :content)
    |> render("show_content.html", page_title: gettext("Content settings"), settings: settings)
  end

  def update(conn, params) do
    user = conn.assigns.current_user
    settings = Settings.get_setting!(user.id)

    with {:ok, settings} <- Settings.update_setting(settings, params) do
      render(conn, "settings.json", settings: settings)
    end
  end

  def show_design(conn, _params) do
    user = conn.assigns.current_user
    settings = Embers.Profile.Settings.get_setting!(user.id)

    conn
    |> assign(:sidebar, :design)
    |> render("show_design.html", page_title: gettext("Design settings"), settings: settings)
  end

  def show_privacy(conn, _params) do
    conn
    |> assign(:sidebar, :privacy)
    |> render("show_privacy.html", page_title: gettext("Privacy settings"))
  end
end
