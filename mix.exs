defmodule Embers.Mixfile do
  use Mix.Project

  def project do
    [
      app: :embers,
      version: app_version(),
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Embers.Application, []},
      extra_applications: [:logger, :runtime_tools, :arc, :recaptcha]
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
      {:distillery, "~> 2.0"},
      {:phauxth, "~> 1.2"},
      {:pbkdf2_elixir, "~> 0.12.3"},
      {:bamboo, "~> 0.8"},
      {:not_qwerty123, "~> 2.3"},
      {:uuid, "~> 1.1"},
      {:arc, "~> 0.10.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.7"},
      {:httpoison, "~> 0.13"},
      {:sweet_xml, "~> 0.6"},
      {:recaptcha, "~> 2.3"},
      {:hashids, "~> 2.0"}
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

  defp app_version do
    with {out, 0} <- System.cmd("git", ~w[describe], stderr_to_stdout: true) do
      out
      |> String.strip()
      |> String.split("-")
      |> Enum.take(2)
      |> Enum.join(".")
      |> String.trim_leading("v")
    else
      _ -> "0.1.0"
    end
  end
end
