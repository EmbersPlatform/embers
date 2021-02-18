defmodule EmbersWeb.UrlProvider do
  @behaviour Embers.UrlProvider

  def confirmation(token) do
    Routes.user_confirmation_url(Endpoint, :confirm, token)
  end

  def email_reset(token) do
    Routes.settings_url(Endpoint, :confirm_email, token)
  end

  def password_reset(token) do
    Routes.user_reset_password_url(Endpoint, :edit, token)
  end
end
