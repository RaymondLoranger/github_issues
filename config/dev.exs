use Mix.Config

config :github_issues, default_count: 9

config :io_ansi_table,
  align_specs: [
    right: "number"
  ]

config :io_ansi_table,
  headers: [
    "number",
    "created_at",
    # "id",
    "title"
  ]

config :io_ansi_table,
  header_fixes: %{
    # ~r[^id$]i => "ID"
    ~r[ at$]i => " at"
  }

config :io_ansi_table,
  sort_specs: [
    "created_at"
  ]

config :log_reset, reset?: true
