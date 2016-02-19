defmodule Elide.Mixfile do
  use Mix.Project

  def project do
    [app: :elide,
     name: "Elide",
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps,
     docs: docs]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Elide, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :oauth2, :hashids, :connection,
                    :con_cache]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.4"},
     {:phoenix_ecto, "~> 2.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.4"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:oauth2, "~> 0.5"},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:mock, "~> 0.1.1", only: :test},
     {:hashids, "~> 2.0"},
     {:ex_doc, "~> 0.11.4", only: :dev},
     {:earmark, "~> 0.2.1", only: :dev},
     {:exrm, "~> 1.0.0-rc7"},
     {:con_cache, "~> 0.11.0"},
     {:exactor, "~> 2.2.0"},
     {:erlware_commons, github: "erlware/erlware_commons", override: true},
     {:cf, "~> 0.2.1", override: true}
   ]
  end

  defp docs do
    [main: "getting-started",
      formatter_opts: [gfm: true],
      extras: [
        "docs/Getting Started.md",
      ]]
  end
  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
