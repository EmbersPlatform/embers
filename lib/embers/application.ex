defmodule Embers.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Embers.PubSub},
      # Start the Ecto repository
      Embers.Repo,
      # Start the endpoint when the application starts
      EmbersWeb.Endpoint,
      EmbersWeb.Telemetry,
      Embers.Audit.Manager,
      Embers.Notifications.Manager,
      Embers.Feed.ActivitySubscriber,
      EmbersWeb.NotificationSubscriber,
      EmbersWeb.ActivitySubscriber,
      EmbersWeb.ChatSubscriber,
      EmbersWeb.ModSubscriber,
      EmbersWeb.Presence,
      {Cachex, name: :embers},
      {Oban, oban_config()}
    ]

    opts = [strategy: :one_for_one, name: Embers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EmbersWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:embers, Oban)
  end
end
