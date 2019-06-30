defmodule EmbersWeb.Remember do
  use Phauxth.Authenticate.Base

  alias Phauxth.Config

  @max_age 7 * 24 * 60 * 60

  @impl Plug
  def init(opts) do
    create_session_func =
      opts[:create_session_func] ||
        raise """
        Phauxth.Remember - you need to set a `create_session_func` in the opts
        """

    unless is_function(create_session_func, 1) do
      raise """
      Phauxth.Remember - the `create_session_func` should be a function
      that takes one argument
      """
    end

    {create_session_func, super(opts ++ [max_age: @max_age])}
  end

  @impl Plug
  def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(%Plug.Conn{req_cookies: %{"remember_me" => _}} = conn, {create_session_func, opts}) do
    conn |> super(opts) |> add_session(create_session_func)
  end

  def call(conn, _), do: conn

  @impl Phauxth.Authenticate.Base
  def authenticate(%Plug.Conn{req_cookies: %{"remember_me" => token}}, user_context, opts) do
    with {:ok, user_id} <- Config.token_module().verify(token, opts),
         do: get_user({:ok, %{"user_id" => user_id}}, user_context)
  end

  @impl Phauxth.Authenticate.Base
  def set_user(nil, conn), do: super(nil, delete_rem_cookie(conn))
  def set_user(user, conn), do: super(user, conn)

  defp add_session(%Plug.Conn{assigns: %{current_user: %{}}} = conn, create_session_func) do
    case create_session_func.(conn) do
      {:ok, %{id: session_id}} ->
        conn
        |> put_session(:phauxth_session_id, session_id)
        |> configure_session(renew: true)

      {:error, _reason} ->
        conn
        |> delete_session(:phauxth_session_id)
        |> delete_rem_cookie()
    end
  end

  defp add_session(conn, _), do: conn

  @doc """
  Adds a remember me cookie to the conn.
  """
  @spec add_rem_cookie(Plug.Conn.t(), integer, integer) :: Plug.Conn.t()
  def add_rem_cookie(conn, user_id, max_age \\ @max_age, extra \\ "") do
    cookie = Config.token_module().sign(user_id, max_age: max_age)
    put_resp_cookie(conn, "remember_me", cookie, http_only: true, max_age: max_age, extra: extra)
  end

  @doc """
  Deletes the remember_me cookie from the conn.
  """
  @spec delete_rem_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end
end
