defmodule GitHub.Issues.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :github_issues,
      version: "0.3.5",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      name: "GitHub Issues",
      source_url: source_url(),
      description: description(),
      package: package(),
      aliases: aliases(),
      escript: escript(),
      deps: deps(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
    ]
  end

  defp source_url() do
    "https://github.com/RaymondLoranger/github_issues"
  end

  defp description() do
    """
    Prints GitHub Issues to STDOUT in a table with borders and colors.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "config/config.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:mix_tasks, path: "../mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.1"},
      {:io_ansi_table, "~> 0.3"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:httpoison, "~> 0.11"},
      {:jsx, "~> 2.0"},
      {:logger_file_backend, "~> 0.0.9"}
    ]
  end

  defp aliases() do
    [
      docs: ["docs", &copy_images/1]
    ]
  end

  defp copy_images(_) do
    File.cp_r("images", "doc/images", fn src, dst ->
      src || dst # => true
      # IO.gets(~s|Overwriting "#{dst}" with "#{src}".\nProceed? [Yn]\s|)
      # in ["y\n", "Y\n"]
    end)
  end

  defp escript() do
    [
      main_module: GitHub.Issues.CLI, name: :gi
    ]
  end
end
