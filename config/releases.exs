import Config

config :embers, Embers.Media, bucket: System.fetch_env!("EMBERS_MEDIA_BUCKET")
config :embers, Embers.Profile, bucket: System.fetch_env!("EMBERS_PROFILE_BUCKET")

# Configure your database
config :embers, Embers.Repo,
  username: System.fetch_env!("DB_USER"),
  password: System.fetch_env!("DB_PWD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  pool_size: 10

# Configure Recaptcha
config :recaptcha,
  public_key: System.fetch_env!("RECAPTCHA_PUBLIC_KEY"),
  secret: System.fetch_env!("RECAPTCHA_SECRET")

config :ex_aws, :s3, %{
  access_key_id: System.fetch_env!("S3_ACCESS_KEY"),
  secret_access_key: System.fetch_env!("S3_SECRET"),
  scheme: "https://",
  host: %{System.fetch_env!("S3_REGION") => System.fetch_env!("DB_HOST")},
  region: System.fetch_env!("S3_REGION")
}
