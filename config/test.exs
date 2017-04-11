
use Mix.Config

config :github_issues, default_count: 5

config :io_ansi_table, headers: [
  "number", "created_at", "state", "id", "title"
]

config :io_ansi_table, header_fixes: %{
  ~r[ at$]i => " at",
  ~r[^id$]i => "ID"
}

config :io_ansi_table, key_headers: ["created_at"]
