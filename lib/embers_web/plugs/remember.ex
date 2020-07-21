defmodule EmbersWeb.Remember do
  @behaviour Plug
  import Plug.Conn

  alias Embers.Sessions
  alias EmbersWeb.Auth.Token

  @max_age :timer.hours(24) * 90

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _) do
    conn
  end

  def call(%Plug.Conn{req_cookies: %{"remember_me" => remember_token}} = conn, _) do
    conn
    |> maybe_renew_session(remember_token)
  end

  def call(conn, _), do: conn

  defp maybe_renew_session(conn, token) do
    with {:ok, user_id} <- Token.verify(token, max_age: @max_age),
         {:ok, %{id: session_id}} <- Sessions.create_session(%{user_id: user_id}) do
      renew_session(conn, user_id, session_id)
    else
      {:error, _reason} -> revoke_sesion(conn)
    end
  rescue
    MatchError -> revoke_sesion(conn)
  end

  defp renew_session(conn, user_id, session_id) do
    conn
    |> put_session(:phauxth_session_id, session_id)
    |> add_rem_cookie(user_id)
    |> configure_session(renew: true)
    |> EmbersWeb.Authenticate.authenticate()
    |> EmbersWeb.Authenticate.report([])
    |> EmbersWeb.Authenticate.set_user(conn)
  end

  defp revoke_sesion(conn) do
    conn
    |> delete_session(:phauxth_session_id)
    |> delete_rem_cookie()
  end

  @doc """
  Adds a remember me cookie to the conn.
  """
  @spec add_rem_cookie(Plug.Conn.t(), integer) :: Plug.Conn.t()
  def add_rem_cookie(conn, user_id) do
    cookie = Token.sign(user_id, max_age: @max_age)
    put_resp_cookie(conn, "remember_me", cookie, http_only: true, max_age: @max_age)
  end

  @doc """
  Deletes the remember_me cookie from the conn.
  """
  @spec delete_rem_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end
end
