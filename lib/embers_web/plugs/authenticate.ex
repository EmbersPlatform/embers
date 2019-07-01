defmodule EmbersWeb.Authenticate do
  @moduledoc false

  alias EmbersWeb.Auth.Token
  alias Embers.Accounts
  import Plug.Conn
  alias Phauxth.{Config, Log}

  def init(opts) do
    {Keyword.get(opts, :user_context, Config.user_context()), Keyword.get(opts, :log_meta, []),
     opts}
  end

  def call(conn, {user_context, log_meta, opts}) do
    conn
    |> authenticate(user_context, opts)
    |> report(log_meta)
    |> set_user(conn)
  end

  def authenticate(conn, _user_context, _opts) do
    case get_session(conn, :phauxth_session_id) do
      nil ->
        {:error, "anonymous user"}

      session_id ->
        case Accounts.get_by(%{"session_id" => session_id}) do
          nil -> {:error, "no user found"}
          user -> {:ok, user}
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
    assign(conn, :current_user, user) |> assign(:user_token, token)
  end
end
