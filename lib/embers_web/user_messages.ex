defmodule EmbersWeb.UserMessages do
  use Phauxth.UserMessages.Base
  import EmbersWeb.Gettext

  def need_confirm, do: gettext("Your account needs to be confirmed")
  def already_confirmed, do: gettext("Your account has already been confirmed")
  def default_error, do: gettext("Invalid credentials")
end
