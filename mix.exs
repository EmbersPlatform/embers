defmodule Embers.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :embers,
      version: "0.2.28",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      source_url: "https://gitlab.com/embers-project/embers/embers",
      docs: docs(),
      default_release: :embers,
      releases: [
        embers: [],
        tar: [
          include_executables_for: [:unix],
          steps: [:assemble, :tar],
          path: "artifacts"
        ]
      ]
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
        :os_mon,
        :recaptcha,
        :ex_rated,
        :swoosh,
        :gen_smtp,
        :mnesia
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
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:sentry, "~> 8.0"},
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_live_view, "~> 0.15.4"},
      {:phoenix_live_dashboard, "~> 0.4.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:ecto_sql, "~> 3.0"},
      {:ecto_psql_extras, "~> 0.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:oban, "~> 2.5.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:ua_inspector, "~> 2.2"},
      {:phoenix_inline_svg, "~> 1.3"},
      {:phoenix_active_link, "~> 0.3.0"},
      {:phx_gen_auth, "~> 0.6.0", only: [:dev], runtime: false},
      {:plug_cowboy, "~> 2.1"},
      {:remote_ip, "~> 0.2.1"},
      {:gettext, "~> 0.11"},
      {:ex_cldr, "~> 2.18"},
      {:ex_cldr_numbers, "~> 2.16"},
      {:ex_cldr_dates_times, "~> 2.6"},
      {:jason, "~> 1.0", override: true},
      {:swoosh, "~> 0.23"},
      {:mail, "~> 0.2"},
      {:gen_smtp, "~> 0.13"},
      {:not_qwerty123, "~> 2.3"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:uuid, "~> 1.1"},
      {:ex_aws, "~> 2.1.5"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.16"},
      {:httpoison, "~> 1.5"},
      {:sweet_xml, "~> 0.6"},
      {:recaptcha, "~> 2.3"},
      {:hashids, "~> 2.0"},
      {:ex_machina, "~> 2.2"},
      {:timex, "~> 3.6"},
      {:mogrify, "~> 0.7.0"},
      {:thumbnex, "~> 0.3.3"},
      {:ffmpex, "~> 0.7"},
      {:silent_video, "~> 0.3.1"},
      {:fastimage, "~> 0.0.7"},
      {:oembed, "~> 0.3.0"},
      {:corsica, "~> 1.0"},
      {:cachex, "~> 3.1"},
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
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
