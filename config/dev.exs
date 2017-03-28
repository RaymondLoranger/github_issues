
use Mix.Config

config :github_issues, default_count: 9

config :io_ansi_table, headers: [
  "number", "created_at", "id", "title"
]

config :io_ansi_table, key_headers: ["created_at"]
