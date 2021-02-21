# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :embers, ecto_repos: [Embers.Repo]

config :embers, EmbersWeb.Cldr,
  default_locale: "en",
  locales: ["en", "es"],
  gettext: EmbersWeb.Gettext,
  data_dir: "./priv/cldr",
  precompile_number_formats: ["¤¤#,##0.##"]

# Configures the endpoint
config :embers, EmbersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HZe8bMvclknQMj38U8sozwTxlyQsABzs3ARC4vKpAsQseTzRntb+/6TC7LZ2gCmY",
  render_errors: [view: EmbersWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Embers.PubSub,
  live_view: [signing_salt: "FkeJaxJqoYAoYlWC"]

config :embers, Embers.Email, host: "localhost"

config :embers, Embers.Profile,
  avatar_path: "user/avatar",
  cover_path: "user/cover"

config :embers, Embers.FileStorage, store: Embers.FileStorage.Store.Local

config :embers, :auth, token_salt: "geDDVmqL"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Mailer configuration
# config :embers, EmbersWeb.Mailer,
#   adapter: Swoosh.SendgridAdapter,
#   api_key: "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"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
