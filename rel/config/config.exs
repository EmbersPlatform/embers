use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :embers, EmbersWeb.Endpoint,
  secret_key_base: "0hvZx7lgtbxPs2xv0qKg8kjo0VosyBZD5ssoATtsEqjOe07mxO6WwbxB+bY5wAMo"

# Configure your database
config :embers, Embers.Repo,
  username: "dorgan",
  password: "dorgan",
  database: "embers_dev",
  hostname: "localhost",
  pool_size: 10

# Configure Recaptcha
config :recaptcha,
  public_key: "6Lde6G4UAAAAAN2QJXkcOnuwzJY4na6SH5vs5ZGl",
  secret: "6Lde6G4UAAAAADV7-DChxeSgFINYadmBHNxkFI2C"

# Configure Arc image and AWS management library
config :arc,
  storage: Arc.Storage.Local,
  storage_dir: "priv/uploads",
  bucket: "embers"

config :ex_aws, :s3, %{
  access_key_id: "BSZN22PL76XYIWMMS3OX",
  secret_access_key: "xUzB9DUrapVaf/9zuT53T1BRg3DyBrudoGN6iDNwz4o",
  scheme: "https://",
  host: %{"nyc3" => "embers.nyc3.digitaloceanspaces.com"},
  region: "nyc3"
}
