import Config

config :embers, Embers.Media, bucket: "local"
config :embers, Embers.Profile, bucket: "local"

# Configure your database
config :embers, Embers.Repo,
  username: "postgres",
  password: "postgres",
  database: "embers_prod",
  hostname: "localhost",
  pool_size: 10

# Configure Recaptcha
config :recaptcha,
  public_key: "6Lde6G4UAAAAAN2QJXkcOnuwzJY4na6SH5vs5ZGl",
  secret: "6Lde6G4UAAAAADV7-DChxeSgFINYadmBHNxkFI2C"

config :ex_aws, :s3, %{
  access_key_id: "URPQ2UQTQQ5DQENPNSLS",
  secret_access_key: "r/SJdSjfx4ow9TIlDsYb42wYHTYGnDDcRIT5cw7fOxU",
  scheme: "https://",
  host: %{"nyc3" => "embers-host.nyc3.digitaloceanspaces.com"},
  region: "nyc3"
}
