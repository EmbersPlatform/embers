# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :embers, ecto_repos: [Embers.Repo]

config :embers, EmbersWeb.Gettext, default_locale: "es"

# Configures the endpoint
config :embers, EmbersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HZe8bMvclknQMj38U8sozwTxlyQsABzs3ARC4vKpAsQseTzRntb+/6TC7LZ2gCmY",
  render_errors: [view: EmbersWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Embers.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "geDDVmqL",
  user_context: Embers.Accounts,
  token_module: EmbersWeb.Auth.Token

# Mailer configuration
config :embers, EmbersWeb.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: "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"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
