# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues.CLI do
  @moduledoc """
  Parses the command line and prints a table of the first or last _n_ issues
  of a GitHub project.

  ##### Inspired by the book [Programming Elixir](https://pragprog.com/book/elixir16/programming-elixir-1-6) by Dave Thomas.

  ##### Reference https://dev.to/paulasantamaria/command-line-interfaces-structure-syntax-2533
  """

  use PersistConfig

  alias GitHub.Issues
  alias GitHub.Issues.{Help, Log, Message}
  alias IO.ANSI.Table
  alias IO.ANSI.Table.Style

  @default_count get_env(:default_count)
  @default_switches get_env(:default_switches)
  @parsing_options get_env(:parsing_options)
  @table_spec get_env(:table_spec)

  @typedoc "GitHub project"
  @type project :: String.t()
  @typedoc "GitHub user"
  @type user :: String.t()

  @doc """
  Parses the command line and prints a table of the first or last _n_ issues
  of a GitHub project.

  `argv` can be "-h" or "--help", which prints info on the command's
  usage and syntax. Otherwise it is a GitHub user, a GitHub project, and
  optionally the number of issues to format (the first _n_ ones).

  To format the last _n_ issues, specify switch `--last`.
  To ring the bell, specify switch `--bell`.
  To choose a table style, specify switch `--table-style`.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help`        - for help
    - `-b` or `--bell`        - to ring the bell
    - `-l` or `--last`        - to format the last _n_ issues
    - `-t` or `--table-style` - to choose a table style

  ## Table styles

  #{Style.texts("\s\s- `&arg`&filler - &note\n")}

  ## Examples

      alias GitHub.Issues.CLI
      CLI.main(["Kraigie", "nostrum", "--last", "--no-help"])
      CLI.main(["Kraigie", "nostrum", "--no-last"])
      CLI.main(["Kraigie", "nostrum", "--no-bell", "--table-style", "plain"])
      CLI.main(["Kraigie", "nostrum", "11", "--last"])
      CLI.main(["Kraigie", "nostrum", "--last", "11"])
  """
  @spec main(OptionParser.argv()) :: :ok
  def main(argv) do
    case OptionParser.parse(argv, @parsing_options) do
      {switches, args, []} -> :ok = maybe_write_table(switches, args)
      _invalid -> :ok = Help.print_help()
    end
  end

  @doc """
  Allows to run command `mix run -e 'GitHub.Issues.CLI.main()'`.

  The above command is equivalent to:\s\s
  `mix run -e 'GitHub.Issues.CLI.main([""Kraigie"", ""nostrum"", ""6""])'`

  ## Examples

      $env:MIX_ENV="test"; mix run -e 'GitHub.Issues.CLI.main()'
      $env:MIX_ENV="dev"; mix run -e 'GitHub.Issues.CLI.main()'
      $env:MIX_ENV="prod"; mix run -e 'GitHub.Issues.CLI.main()'
  """
  @spec main :: :ok
  def main do
    :ok = main(["Kraigie", "nostrum", "6"])
  end

  ## Private functions

  @spec maybe_write_table(Keyword.t(), OptionParser.argv()) :: :ok
  defp maybe_write_table(switches, [user, project]) do
    maybe_write_table(switches, [user, project, @default_count])
  end

  defp maybe_write_table(switches, [user, project, count]) do
    with %{help: false, bell: bell?, last: last?, table_style: style} <-
           Map.merge(@default_switches, Map.new(switches)),
         {:ok, style} <- Style.from_switch_arg(style),
         {count, ""} when count > 0 <- Integer.parse(count),
         count = if(last?, do: -count, else: count),
         options = [count: count, bell: bell?, style: style] do
      :ok = write_table(user, project, options)
    else
      :error -> :ok = Help.print_help()
    end
  end

  defp maybe_write_table(_switches, _args) do
    :ok = Help.print_help()
  end

  @spec write_table(user, project, Keyword.t()) :: :ok
  defp write_table(user, project, options) do
    case Issues.fetch(user, project) do
      {:ok, issues} ->
        :ok = Message.writing_table(user, project)
        :ok = Log.info(:writing_table, {user, project, __ENV__})
        :ok = Table.write(@table_spec, issues, options)

      {:error, text} ->
        :ok = Message.fetching_error(user, project, text)
        :ok = Log.error(:fetching_error, {user, project, text, __ENV__})
    end
  end
end
