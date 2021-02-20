import Config

config :embers, EmbersWeb.Gettext, default_locale: System.get_env("DEFAULT_LOCALE", "en")

config :logger,
  level: :info,
  backends: [:console, Sentry.LoggerBackend]

config :embers, EmbersWeb.Endpoint,
  http: [port: System.fetch_env!("PORT"), compress: true],
  url: [host: System.fetch_env!("EMBERS_HOST"), port: System.fetch_env!("PORT")],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  check_origin: false

config :embers, Embers.Media, bucket: System.fetch_env!("EMBERS_MEDIA_BUCKET")
config :embers, Embers.Profile, bucket: System.fetch_env!("EMBERS_PROFILE_BUCKET")
config :embers, Embers.Email, host: System.get_env("MAIL_HOST", System.fetch_env!("EMBERS_HOST"))

# Configure your database
repo_opts =
  case System.fetch_env("DB_URL") do
    :error ->
      [
        username: System.fetch_env!("DB_USER"),
        password: System.fetch_env!("DB_PWD"),
        database: System.fetch_env!("DB_NAME"),
        hostname: System.fetch_env!("DB_HOST")
      ]

    {:ok, url} ->
      [url: url]
  end

config :embers,
       Embers.Repo,
       Keyword.merge(repo_opts,
         pool_size: System.get_env("DB_POOL_SIZE", "10") |> String.to_integer()
       )

config :embers, :db_extensions, pg_trgm: System.get_env("DB_ENABLE_PG_TRGM", "true") == "true"

# Configure Recaptcha
config :recaptcha,
  public_key: System.fetch_env!("RECAPTCHA_PUBLIC_KEY"),
  secret: System.fetch_env!("RECAPTCHA_SECRET")

case System.get_env("EMBERS_STORAGE_DRIVER", "local") do
  "local" ->
    config :embers, Embers.FileStorage, store: Embers.FileStorage.Store.Local

  "s3" ->
    config :ex_aws, :s3, %{
      access_key_id: System.fetch_env!("S3_ACCESS_KEY"),
      secret_access_key: System.fetch_env!("S3_SECRET"),
      scheme: "https://",
      host: System.fetch_env!("S3_HOST"),
      region: System.fetch_env!("S3_REGION")
    }

    config :embers, Embers.FileStorage,
      store: Embers.FileStorage.Store.S3,
      bucket: System.get_env("S3_BUCKET", "uploads"),
      bucket_root: System.get_env("S3_BUCKET", ""),
      schema: "https://",
      host: System.fetch_env!("S3_HOST_URL")
end

case System.fetch_env!("MAIL_ADAPTER") do
  "sendgrid" ->
    config :embers, Embers.Mailer,
      adapter: Swoosh.Adapters.Sendgrid,
      api_key: System.fetch_env!("SENDGRID_API_KEY")

  "smtp" ->
    config :embers, Embers.Mailer,
      adapter: Swoosh.Adapters.SMTP,
      relay: System.fetch_env!("MAIL_RELAY"),
      username: System.fetch_env!("MAIL_USERNAME"),
      password: System.fetch_env!("MAIL_PASSWORD"),
      ssl: false,
      auth: :always,
      port: System.fetch_env!("MAIL_SMTP_PORT")
end

case System.fetch_env("SENTRY_ENABLE") do
  {:ok, "true"} ->
    config :sentry,
      dsn: System.fetch_env!("SENTRY_DSN"),
      environment_name: :prod,
      enable_source_code_context: true,
      root_source_code_path: File.cwd!(),
      tags: %{
        env: "production"
      },
      included_environments: [:prod]

  _ ->
    nil
end
