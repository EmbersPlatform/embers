defmodule EmbersWeb.ConfirmController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Accounts

  def index(conn, params) do
    case Phauxth.Confirm.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        message = "Your account has been confirmed"
        Accounts.Message.confirm_success(user.email)
        success(conn, message, session_path(conn, :new))

      {:error, message} ->
        error(conn, message, session_path(conn, :new))
    end
  end
end
