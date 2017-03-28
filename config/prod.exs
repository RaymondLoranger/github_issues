
use Mix.Config

config :github_issues, default_count: 7

config :io_ansi_table, headers: [
  "number", "created_at", "updated_at", "id", "title", "state"
]

config :io_ansi_table, key_headers: ["created_at"]
