# Borrowed from https://github.com/webstronauts/ex_unpoly
# `mix deps.get` errors because of mismatching elixir versions
# Maybe I should fork or open a pull request
# Also there was a bug because it originally tries to get the conn's router
# before phoenix's router get's the chance to run

defmodule Unpoly do
  @moduledoc """
  A Plug adapter and helpers for Unpoly, the unobtrusive JavaScript framework.
  ## Options
    * `:cookie_name` - the cookie name where the request method is echoed to. Defaults to
    `"_up_method"`.
    * `:cookie_opts` - additional options to pass to method cookie.
    See `Plug.Conn.put_resp_cookie/4` for all available options.
  """

  @doc """
  Alias for `Unpoly.unpoly?/1`
  """
  @spec up?(Plug.Conn.t()) :: boolean()
  def up?(conn), do: unpoly?(conn)

  @doc """
  Returns whether the current request is a [page fragment update](https://unpoly.com/up.replace)
  triggered by an Unpoly frontend.
  """
  @spec unpoly?(Plug.Conn.t()) :: boolean()
  def unpoly?(conn), do: target(conn) !== nil

  @doc """
  Returns the CSS selector for a fragment that Unpoly will update in
  case of a successful response (200 status code).
  The Unpoly frontend will expect an HTML response containing an element
  that matches this selector.
  Server-side code is free to optimize its successful response by only returning HTML
  that matches this selector.
  """
  @spec target(Plug.Conn.t()) :: String.t() | nil
  def target(conn), do: get_req_header(conn, "x-up-target")

  @doc """
  Returns the CSS selector for a fragment that Unpoly will update in
  case of an failed response. Server errors or validation failures are
  all examples for a failed response (non-200 status code).
  The Unpoly frontend will expect an HTML response containing an element
  that matches this selector.
  Server-side code is free to optimize its response by only returning HTML
  that matches this selector.
  """
  @spec fail_target(Plug.Conn.t()) :: String.t() | nil
  def fail_target(conn), do: get_req_header(conn, "x-up-fail-target")

  @doc """
  Returns whether the given CSS selector is targeted by the current fragment
  update in case of a successful response (200 status code).
  Note that the matching logic is very simplistic and does not actually know
  how your page layout is structured. It will return `true` if
  the tested selector and the requested CSS selector matches exactly, or if the
  requested selector is `body` or `html`.
  Always returns `true` if the current request is not an Unpoly fragment update.
  """
  @spec target?(Plug.Conn.t(), String.t()) :: boolean()
  def target?(conn, tested_target), do: query_target(conn, target(conn), tested_target)

  @doc """
  Returns whether the given CSS selector is targeted by the current fragment
  update in case of a failed response (non-200 status code).
  Note that the matching logic is very simplistic and does not actually know
  how your page layout is structured. It will return `true` if
  the tested selector and the requested CSS selector matches exactly, or if the
  requested selector is `body` or `html`.
  Always returns `true` if the current request is not an Unpoly fragment update.
  """
  @spec fail_target?(Plug.Conn.t(), String.t()) :: boolean()
  def fail_target?(conn, tested_target), do: query_target(conn, fail_target(conn), tested_target)

  @doc """
  Returns whether the given CSS selector is targeted by the current fragment
  update for either a success or a failed response.
  Note that the matching logic is very simplistic and does not actually know
  how your page layout is structured. It will return `true` if
  the tested selector and the requested CSS selector matches exactly, or if the
  requested selector is `body` or `html`.
  Always returns `true` if the current request is not an Unpoly fragment update.
  """
  @spec any_target?(Plug.Conn.t(), String.t()) :: boolean()
  def any_target?(conn, tested_target),
    do: target?(conn, tested_target) || fail_target?(conn, tested_target)

  @doc """
  Returns whether the current form submission should be
  [validated](https://unpoly.com/input-up-validate) (and not be saved to the database).
  """
  @spec validate?(Plug.Conn.t()) :: boolean()
  def validate?(conn), do: validate_name(conn) !== nil

  @doc """
  If the current form submission is a [validation](https://unpoly.com/input-up-validate),
  this returns the name attribute of the form field that has triggered
  the validation.
  """
  @spec validate_name(Plug.Conn.t()) :: String.t() | nil
  def validate_name(conn), do: get_req_header(conn, "x-up-validate")

  @doc """
  Forces Unpoly to use the given string as the document title when processing
  this response.
  This is useful when you skip rendering the `<head>` in an Unpoly request.
  """
  @spec put_title(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def put_title(conn, new_title), do: Plug.Conn.put_resp_header(conn, "x-up-title", new_title)

  # Plug

  def init(opts \\ []) do
    cookie_name = Keyword.get(opts, :cookie_name, "_up_method")
    cookie_opts = Keyword.get(opts, :cookie_opts, http_only: false)
    {cookie_name, cookie_opts}
  end

  def call(conn, {cookie_name, cookie_opts}) do
    conn
    |> Plug.Conn.fetch_cookies()
    |> echo_request_headers()
    |> append_method_cookie(cookie_name, cookie_opts)
  end

  @doc """
  Sets the value of the "x-up-location" response header.
  """
  @spec put_resp_location_header(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def put_resp_location_header(conn, value) do
    Plug.Conn.put_resp_header(conn, "x-up-location", value)
  end

  @doc """
  Sets the value of the "x-up-method" response header.
  """
  @spec put_resp_method_header(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def put_resp_method_header(conn, value) do
    Plug.Conn.put_resp_header(conn, "x-up-method", value)
  end

  defp echo_request_headers(conn) do
    conn
    |> put_resp_location_header(conn.request_path)
    |> put_resp_method_header(conn.method)
  end

  defp append_method_cookie(conn, cookie_name, cookie_opts) do
    cond do
      conn.method != "GET" && !up?(conn) ->
        Plug.Conn.put_resp_cookie(conn, cookie_name, conn.method, cookie_opts)

      Map.has_key?(conn.req_cookies, "_up_method") ->
        Plug.Conn.delete_resp_cookie(conn, cookie_name, cookie_opts)

      true ->
        conn
    end
  end

  ## Helpers

  defp get_req_header(conn, key),
    do: Plug.Conn.get_req_header(conn, key) |> List.first()

  defp query_target(conn, actual_target, tested_target) do
    if up?(conn) do
      cond do
        actual_target == tested_target -> true
        actual_target == "html" -> true
        actual_target == "body" && tested_target not in ["head", "title", "meta"] -> true
        true -> false
      end
    else
      true
    end
  end
end
