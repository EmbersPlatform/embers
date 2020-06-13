defmodule Embers.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :embers,
      version: "0.2.11",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      source_url: "https://gitlab.com/embers-project/embers/embers",
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Embers.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :recaptcha,
        :scrivener_ecto,
        :scrivener_html,
        :ex_rated,
        :swoosh,
        :gen_smtp
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phauxth, "~> 2.1"},
      {:swoosh, "~> 0.23"},
      {:mail, "~> 0.2"},
      {:gen_smtp, "~> 0.13"},
      {:not_qwerty123, "~> 2.3"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:uuid, "~> 1.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.7"},
      {:httpoison, "~> 1.5"},
      {:sweet_xml, "~> 0.6"},
      {:recaptcha, "~> 2.3"},
      {:hashids, "~> 2.0"},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2"},
      {:timex, "~> 3.0"},
      {:mogrify, "~> 0.7.0"},
      {:ffmpex, "~> 0.5.2"},
      {:silent_video, "~> 0.3.0"},
      {:event_bus, "~> 1.6"},
      {:corsica, "~> 1.0"},
      {:cachex, "~> 3.1"},
      {:oembed, "~> 0.3.0"},
      {:fastimage, "~> 0.0.7"},
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:scrivener_ecto, "~> 2.0"},
      {:scrivener_html, "~> 1.8"},
      {:ex_rated, "~> 1.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "docs/deletes.md"],
      groups_for_modules: [
        Accounts: ~r/^Embers.Accounts/,
        Audit: ~r/^Embers.Audit/,
        Authorization: ~r/^Embers.Authorization/,
        Blocks: ~r/^Embers.Blocks/,
        Chat: ~r/^Embers.Chat/,
        Events: ~r/^Embers.Events/,
        Favorites: ~r/^Embers.Favorites/,
        Feed: ~r/^Embers.Feed/,
        "File Storage": ~r/^Embers.FileStorage/,
        Helpers: ~r/^Embers.Helpers/,
        Links: ~r/^Embers.Links/,
        "Loading Messages": ~r/^Embers.LoadingMsg/,
        Media: ~r/^Embers.Media/,
        Moderation: ~r/^Embers.Moderation/,
        Notifications: ~r/^Embers.Notifications/,
        OpenGraph: ~r/^Embers.OpenGraph/,
        Paginator: ~r/^Embers.Paginator/,
        Posts: ~r/^Embers.Posts/,
        Profile: ~r/^Embers.Profile/,
        Reactions: ~r/^Embers.Reactions/,
        Reports: ~r/^Embers.Reports/,
        Search: ~r/^Embers.Search/,
        Sessions: ~r/^Embers.Sessions/,
        Settings: ~r/^Embers.Settings/,
        Subscriptions: ~r/^Embers.Subscriptions/,
        Tags: ~r/^Embers.Tags/,
        Uploads: ~r/^Embers.Uploads/,
        Plugs: ~r/^EmbersWeb.Plugs/,
        "Web layer": ~r/^EmbersWeb/
      ]
    ]
  end
end
