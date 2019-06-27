use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :embers, EmbersWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :embers, Embers.Repo,
  username: "postgres",
  password: "postgres",
  database: "embers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Comeonin password hashing test config
# config :argon2_elixir,
# t_cost: 2,
# m_cost: 8
# config :bcrypt_elixir, log_rounds: 4
config :pbkdf2_elixir, rounds: 1

# Mailer test configuration
config :embers, Embers.Mailer, adapter: Bamboo.TestAdapter
