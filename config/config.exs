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

config :embers, Embers.Email, host: "localhost"

config :embers, Embers.Profile,
  avatar_path: "user/avatar",
  cover_path: "user/cover"

config :embers, Embers.FileStorage, store: Embers.FileStorage.Store.Local

# Phauxth authentication configuration
config :phauxth,
  token_salt: "geDDVmqL",
  user_context: Embers.Accounts,
  token_module: EmbersWeb.Auth.Token,
  user_messages: EmbersWeb.UserMessages

config :embers, :auth, token_salt: "geDDVmqL"

# Mailer configuration
config :embers, EmbersWeb.Mailer,
  adapter: Swoosh.SendgridAdapter,
  api_key: "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"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :fun_with_flags, :cache,
  enabled: true,
  ttl: 900

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: Embers.Repo

config :fun_with_flags, :cache_bust_notifications, enabled: false

config :event_bus,
  topics: [
    :post_created,
    :post_comment,
    :post_disabled,
    :post_deleted,
    :post_shared,
    :post_updated,
    :post_restored,
    :post_reacted,
    :comment_reply,
    :comment_reacted,
    :notification_created,
    :created_notificaion_failed,
    :user_created,
    :user_followed,
    :user_mentioned,
    :user_updated,
    :user_banned,
    :new_activity,
    :chat_message_created,
    :chat_message_deleted,
    :chat_message_updated
  ]

config :scrivener_html,
  routes_helper: Embers.Router.Helpers,
  view_style: :bulma

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
