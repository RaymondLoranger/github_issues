import Config

config :github_issues, default_count: "9"

config :github_issues,
  default_switches: %{
    help: false,
    bell: false,
    last: false,
    table_style: "medium"
  }

config :github_issues,
  parsing_options: [
    strict: [
      help: :boolean,
      bell: :boolean,
      last: :boolean,
      table_style: :string
    ],
    aliases: [h: :help, b: :bell, l: :last, t: :table_style]
  ]
