defmodule EmbersWeb.RateLimit do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1]

  def rate_limit(conn, options \\ []) do
    case check_rate(conn, options) do
      # Do nothing, pass on to the next plug
      {:ok, _count} -> conn
      {:error, _count} -> render_error(conn)
    end
  end

  def limited?(bucket, interval, limit) do
    {_, count, _, _, _} = ExRated.inspect_bucket(bucket, interval, limit)
    count <= 0
  end

  def peek_rate(bucket, interval, limit) do
    case limited?(bucket, interval, limit) do
      true -> :rate_limited
      false -> :ok
    end
  end

  defp check_rate(conn, options) do
    interval_milliseconds = options[:interval_seconds] * 1000
    max_requests = options[:max_requests]
    bucket_name = options[:bucket_name] || bucket_name(conn)

    ExRated.check_rate(bucket_name, interval_milliseconds, max_requests)
  end

  # Bucket name should be a combination of ip address and request path, like so:
  #
  # "127.0.0.1:/api/v1/authorizations"
  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    "#{ip}:#{path}"
  end

  defp render_error(conn) do
    conn
    |> put_status(:too_many_requests)
    |> json(%{error: :rate_limited})
    # Stop execution of further plugs, return response now
    |> halt
  end
end
