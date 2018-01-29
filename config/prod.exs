use Mix.Config

config :github_issues, default_count: 7

config :io_ansi_table,
  align_specs: [
    right: "number"
  ]

config :io_ansi_table,
  headers: [
    "number",
    "created_at",
    "updated_at",
    "id",
    "title",
    "state"
  ]

config :io_ansi_table,
  header_fixes: %{
    ~r[ at$]i => " at",
    ~r[^id$]i => "ID"
  }

config :io_ansi_table,
  sort_specs: [
    "created_at"
  ]
