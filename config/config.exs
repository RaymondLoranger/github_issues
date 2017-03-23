# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :github_issues, key: :value

config :elixir, ansi_enabled: true # mix messages in colors

config :github_issues, aliases: [
  h: :help, l: :last, b: :bell, t: :table_style
]

config :github_issues, default_switches: [
  help: false, last: false, bell: false, table_style: "medium"
]

config :github_issues, strict: [
  help: :boolean, last: :boolean, bell: :boolean, table_style: :string
]

config :github_issues, url_template:
  "https://api.github.com/repos/{user}/{project}/issues"

# config :io_ansi_table, margins: [
#   top:    1, # line(s) before table
#   bottom: 1, # line(s) after table
#   left:   2  # space(s) left of table
# ]

config :logger, compile_time_purge_level: :info

#
# And access this configuration in your application as:
#
#     Application.get_env(:github_issues, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

import_config "#{Mix.env}.exs"
