defmodule EmbersWeb.Plugs.UserToken do
  alias EmbersWeb.Auth.Token
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Pow.Plug.current_user(conn)

    if user do
      token = Token.sign(%{"user_id" => user.id})

      conn
      |> assign(:user_token, token)
    else
      conn
    end
  end
end
