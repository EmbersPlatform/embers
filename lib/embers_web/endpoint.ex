defmodule EmbersWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :embers

  plug(RemoteIp)

  @session_options [
    store: :cookie,
    # 7 days
    # max_age: 24 * 60 * 60 * 7,
    key: "_embers_key",
    signing_salt: "8LHeFKPR",
    same_site: "Strict"
  ]

  socket("/socket", EmbersWeb.UserSocket)
  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :embers,
    gzip: true,
    only:
      ~w(dist fonts uploads locales img svg images emoji favicon.ico robots.txt manifest.json offline.html error.html service-worker.js)
  )

  plug(Plug.Static, at: "/user/avatar", from: Path.expand('./uploads/user/avatar'), gzip: true)
  plug(Plug.Static, at: "/user/cover", from: Path.expand('./uploads/user/cover'), gzip: true)

  plug(
    Plug.Static,
    at: "/media",
    from: Path.expand('./uploads/media'),
    gzip: true
  )

  plug(
    Plug.Static,
    at: "/legacy",
    from: Path.expand('./legacy'),
    gzip: true
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason,
    length: 5_000_000
  )

  plug(Sentry.PlugContext)

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    @session_options
  )

  plug(EmbersWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end

  @doc false
  def on_response(status, headers, _body, request) do
    {status, List.keyreplace(headers, "server", 0, {"server", "Magic Potato"}), request}
  end
end
