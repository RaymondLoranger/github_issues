# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixir, ansi_enabled: true # mix messages in colors

config :github_issues, aliases: [
  h: :help, l: :last, b: :bell, t: :table_style
]
config :github_issues, default_switches: [
  help: false, last: false, bell: false, table_style: "medium"
]
config :github_issues, help_attrs: %{
  arg:     :light_cyan,
  command: :light_yellow,
  normal:  :reset,
  section: :light_green,
  switch:  :light_yellow,
  value:   :light_magenta
}
config :github_issues, strict: [
  help: :boolean, last: :boolean, bell: :boolean, table_style: :string
]
config :github_issues, url_template:
  "https://api.github.com/repos/{user}/{project}/issues"

# config :io_ansi_table, async: true # truthy -> cast; falsy -> call
config :io_ansi_table, margins: [
  top:    0, # line(s) before table
  bottom: 0, # line(s) after table
  left:   1  # space(s) left of table
]
# config :io_ansi_table, max_width: 88

config :logger, backends: [
  :console,
  {LoggerFileBackend, :error_log},
  {LoggerFileBackend, :info_log}
]
config :logger, compile_time_purge_level: :info # purges debug messages
config :logger, level: :info # prevents debug messages
config :logger, :console, colors: [
  debug: :light_cyan,
  info:  :light_green,
  warn:  :light_yellow,
  error: :light_red
]
format = "$date $time [$level] $levelpad$message\n"
config :logger, :console, format: format
config :logger, :error_log, format: format
config :logger, :error_log, path: "./log/error.log", level: :error
config :logger, :info_log, format: format
config :logger, :info_log, path: "./log/info.log", level: :info

import_config "#{Mix.env}.exs"
