defmodule EmbersWeb.Authenticate do
  use Phauxth.Authenticate.Base

  alias EmbersWeb.Auth.Token

  @impl true
  def set_user(nil, conn), do: assign(conn, :current_user, nil)

  @impl true
  def set_user(user, conn) do
    token = Token.sign(%{"user_id" => user.id})
    user |> super(conn) |> assign(:user_token, token)
  end
end
