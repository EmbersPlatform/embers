import Config

config :embers, Oban,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"0 * * * *", Embers.Accounts.TokensPruner}
     ]}
  ]
