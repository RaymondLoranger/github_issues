# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues.CLI do
  @moduledoc """
  Parses the command line and generates a table of
  the first or last _n_ issues of a GitHub project.
  """

  use PersistConfig

  alias GitHub.Issues
  alias GitHub.Issues.Help
  alias IO.ANSI.Table
  alias IO.ANSI.Table.Style

  require Logger

  @type bell :: boolean
  @type count :: integer
  @type parsed :: {user, project, count, bell, Style.t()} | :help
  @type project :: String.t()
  @type user :: String.t()

  @aliases Application.get_env(@app, :aliases)
  @async Application.get_env(:io_ansi_table, :async)
  @count Application.get_env(@app, :default_count)
  @strict Application.get_env(@app, :strict)
  @switches Application.get_env(@app, :default_switches)

  @doc """
  Parses and processes `argv` (command line arguments).

  ## Parameters

    - `argv` - command line arguments (list)
  """
  @spec main([String.t()]) :: :ok | no_return
  def main(argv) do
    with {user, project, count, bell, style} <- parse(argv),
         {:ok, issues} <- Issues.fetch(user, project) do
      Table.format(issues, count: count, bell: bell, style: style)
      # Ensure table has printed before returning...
      Process.sleep((@async && 2000) || 0)
    else
      :help -> Help.show_help()
      {:error, text} -> log_error(text)
      any -> log_error("unknown: #{inspect(any)}")
    end
  end

  @doc """
  Parses `argv` (command line arguments).

  `argv` can be ["-h"] or ["--help"], which returns :help. Otherwise
  it contains a user name, project name, and optionally the number
  of issues to format (the first _n_ ones). To format the last _n_
  issues, specify switch `--last` which will return a negative count.
  To ring the bell, specify switch `--bell`. To apply a specific
  table style, use switch `--table-style`.

  Returns either a tuple of {user, project, count, bell, table_style}
  or :help if `--help` was specified.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help`        - for help
    - `-l` or `--last`        - to format the last _n_ issues
    - `-b` or `--bell`        - to ring the bell
    - `-t` or `--table-style` - to apply a specific table style

  ## Table styles

  #{Style.texts("\s\s- `&arg`&filler - &note\n")}

  ## Examples

      iex> alias GitHub.Issues.CLI
      iex> CLI.parse(["-h"])
      :help

      iex> alias GitHub.Issues.CLI
      iex> CLI.parse(["user", "project", "99"])
      {"user", "project", 99, false, :medium}

      iex> alias GitHub.Issues.CLI
      iex> CLI.parse(["user", "project", "88", "--last", "--bell"])
      {"user", "project", -88, true, :medium}

      iex> alias GitHub.Issues.CLI
      iex> CLI.parse(["user", "project", "6", "--table-style", "dark"])
      {"user", "project", 6, false, :dark}
  """
  @spec parse([String.t()]) :: parsed
  def parse(argv) do
    argv
    |> OptionParser.parse(strict: @strict, aliases: @aliases)
    |> to_parsed()
  end

  ## Private functions

  @spec log_error(String.t()) :: no_return
  defp log_error(text) do
    Logger.error("Error fetching from GitHub - #{text}")
    # Ensure message logged before exiting...
    Process.sleep(1000)
    System.halt(2)
  end

  @spec to_parsed({Keyword.t(), [String.t()], [tuple]}) :: parsed
  defp to_parsed({switches, args, []}) do
    with {user, project, count} <- to_tuple(args),
         %{help: false, last: last, bell: bell, table_style: table_style} <-
           Map.merge(Map.new(@switches), Map.new(switches)),
         {:ok, style} <- Style.from_switch_arg(table_style),
         do: {user, project, (last && -count) || count, bell, style},
         else: (_ -> :help)
  end

  defp to_parsed(_), do: :help

  @spec to_tuple([String.t()]) :: {user, project, non_neg_integer} | :error
  defp to_tuple([user, project, count]) do
    with {int, ""} when int >= 0 <- Integer.parse(count),
         do: {user, project, int},
         else: (_ -> :error)
  end

  defp to_tuple([user, project]), do: {user, project, @count}
  defp to_tuple(_), do: :error
end
