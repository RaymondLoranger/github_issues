use Mix.Config

config :github_issues,
  aliases: [
    h: :help,
    l: :last,
    b: :bell,
    t: :table_style
  ]

config :github_issues,
  default_switches: [
    help: false,
    last: false,
    bell: false,
    table_style: "medium"
  ]

config :github_issues,
  help_attrs: %{
    arg: :light_cyan,
    command: :light_yellow,
    normal: :reset,
    section: :light_green,
    switch: :light_yellow,
    value: :light_magenta
  }

config :github_issues,
  home_page: "https://pragprog.com/book/elixir16/programming-elixir-1-6"

config :github_issues,
  strict: [
    help: :boolean,
    last: :boolean,
    bell: :boolean,
    table_style: :string
  ]

config :github_issues,
  url_template: "https://api.github.com/repos/{user}/{project}/issues"
