defmodule Embers.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Embers.Repo, []),
      # Start the endpoint when the application starts
      supervisor(EmbersWeb.Endpoint, []),
      # Start your own worker by calling: Embers.Worker.start_link(arg1, arg2, arg3)
      # worker(Embers.Worker, [arg1, arg2, arg3]),
      EmbersWeb.Presence,
      worker(Cachex, [:embers, []]),
      supervisor(Task.Supervisor, [[name: TaskSupervisor, restart: :transient]])
    ]

    Embers.Audit.Manager.register()
    Embers.Feed.ActivitySubscriber.register()
    Embers.Notifications.Manager.register()
    EmbersWeb.NotificationSubscriber.register()
    EmbersWeb.ActivitySubscriber.register()
    EmbersWeb.ChatSubscriber.register()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Embers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EmbersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
