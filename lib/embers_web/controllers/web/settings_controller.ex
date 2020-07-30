defmodule EmbersWeb.Web.SettingsController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Profile
  alias Embers.Profile.Meta
  alias Embers.Profile.Settings

  action_fallback(EmbersWeb.Web.SettingsFallbackController)

  plug(:user_check)

  def show_account(conn, _params) do
    user = conn.assigns.current_user
    profile = Embers.Profile.get_meta_for(user.id)

    conn
    |> render("show_account.html",
      user: user,
      profile: profile
    )
  end

  def update_account(conn, params) do
    IO.inspect(params)
    conn
    |> show_account(params)
  end

  def show_profile(conn, _params) do
    user = conn.assigns.current_user
    profile = Embers.Profile.get_meta_for(user.id)

    conn
    |> render("show_profile.html",
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
    |> IO.inspect(label: "ERROR")
  end

  def show_content(conn, _params) do
    user = conn.assigns.current_user
    settings = Embers.Profile.Settings.get_setting!(user.id)

    render(conn, "show_content.html", settings: settings)
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

    render(conn, "show_design.html", settings: settings)
  end

  def show_privacy(conn, _params) do
    render(conn, "show_privacy.html")
  end

  def show_security(conn, _params) do
    render(conn, "show_security.html")
  end


  def reset_pass(conn, _params) do
    email = conn.assigns.current_user.email

    rate_limit = EmbersWeb.RateLimit.peek_rate(
      "reset_password:#{email}",
      :timer.minutes(1), 1
    )

    with(
      :ok <- rate_limit,
      {:ok, _} = Embers.Accounts.create_password_reset(%{"email" => email})
    ) do
      key = EmbersWeb.Auth.Token.sign(%{"email" => email})
      EmbersWeb.Email.reset_request(email, key)

      ExRated.check_rate(
        "reset_password:#{email}",
        :timer.minutes(1), 1
      )

      conn |> put_status(:no_content) |> json(nil)
    else
      :rate_limited ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: :rate_limited})
    end
  end
end
