import Config

alias IO.ANSI.Table.Spec

headers =
  case Mix.env() do
    :dev -> ["number", "created_at", "title"]
    :prod -> ["number", "created_at", "updated_at", "title", "state"]
    :test -> ["number", "created_at", "state", "title"]
  end

options = [
  align_specs: [right: "number"],
  header_fixes: %{~r[ at$]i => " at"},
  sort_specs: ["created_at"],
  margins: [top: 0, bottom: 0, left: 1]
]

config :github_issues, table_spec: Spec.new(headers, options) |> Spec.extend()
