defmodule GitHub.Issues.Mixfile do
  use Mix.Project

  def project do
    [
      app: :github_issues,
      version: "0.4.65",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "GitHub Issues",
      source_url: source_url(),
      description: description(),
      package: package(),
      # aliases: aliases(),
      escript: escript(),
      deps: deps(),
      # See GitHub.Issues.URLTemplate.url/3...
      # See GitHub.Issues.CLI.write_table/3...
      dialyzer: [plt_add_apps: [:eex, :io_ansi_table]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/github_issues"
  end

  defp description do
    """
    Writes GitHub Issues to "stdio" in a table with borders and colors.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # Only using the `IO.ANSI.Table.write/3` function.
      included_applications: [:io_ansi_table],
      extra_applications: [:eex, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:file_only_logger, "~> 0.2"},
      # {:file_only_logger, path: "../file_only_logger"},
      {:httpoison, "~> 2.0"},
      {:io_ansi_plus, "~> 0.1"},
      {:io_ansi_table, "~> 1.0"},
      # {:io_ansi_table, path: "../io_ansi_table"},
      {:jsx, "~> 3.0"},
      {:log_reset, "~> 0.1"},
      # {:log_reset, path: "../log_reset"},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end

  # @cmd "xcopy images doc\\images /Y"

  # defp aliases do
  #   [
  #     docs: ["docs", &echo_xcopy/1, "cmd #{@cmd}"]
  #   ]
  # end

  # defp echo_xcopy(_) do
  #   IO.ANSI.Plus.puts([:light_yellow, @cmd])
  # end

  defp escript do
    [
      main_module: GitHub.Issues.CLI,
      name: :gi
    ]
  end
end
