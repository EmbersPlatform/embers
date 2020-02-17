defmodule EmbersWeb.Authenticate do
  @moduledoc false

  alias EmbersWeb.Auth.Token
  alias Embers.Accounts
  import Plug.Conn
  alias Phauxth.{Config, Log}

  def init(opts) do
    {Keyword.get(opts, :log_meta, []), opts}
  end

  def call(conn, {log_meta, _opts}) do
    conn
    |> authenticate()
    |> report(log_meta)
    |> set_user(conn)
  end

  def authenticate(conn) do
    case get_session(conn, :phauxth_session_id) do
      nil ->
        {:error, "anonymous user"}

      session_id ->
        case Accounts.get_by(%{"session_id" => session_id}) do
          nil ->
            {:error, "no user found"}

          user ->
            {:ok, user}
        end
    end
  end

  def report({:ok, user}, meta) do
    Log.info(%Log{user: user.id, message: "user authenticated", meta: meta})
    Map.drop(user, Config.drop_user_keys())
  end

  def report({:error, message}, meta) do
    Log.info(%Log{message: message, meta: meta})
    nil
  end

  def set_user(nil, conn), do: assign(conn, :current_user, nil)

  def set_user(user, conn) do
    token = Token.sign(%{"user_id" => user.id})

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
    |> EmbersWeb.Remember.add_rem_cookie(user.id)
  end
end
