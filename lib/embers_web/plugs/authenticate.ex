defmodule EmbersWeb.Authenticate do
  use Phauxth.Authenticate.Base

  def set_user(nil, conn) do
    assign(conn, :current_user, nil)
    |> assign(:user_token, nil)
  end

  def set_user(user, conn) do
    token = Phauxth.Token.sign(conn, %{"user_id" => user.id})

    assign(conn, :current_user, user)
    |> assign(:user_token, token)
  end
end
