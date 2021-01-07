# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues.CLI do
  @moduledoc """
  Parses the command line and prints a table of the first or last _n_ issues
  of a GitHub project.

  ##### Inspired by the book [Programming Elixir](https://pragprog.com/book/elixir16/programming-elixir-1-6) by Dave Thomas.
  """

  use PersistConfig

  alias GitHub.Issues
  alias GitHub.Issues.{Help, Log}
  alias IO.ANSI.Table
  alias IO.ANSI.Table.Style

  @aliases get_env(:aliases)
  @count get_env(:default_count)
  @strict get_env(:strict)
  @switches get_env(:default_switches)
  @table_spec get_env(:table_spec)

  @type bell :: boolean
  @type count :: pos_integer
  @type parsed :: {user, project, count, bell, Style.t()} | :help
  @type project :: String.t()
  @type user :: String.t()

  @doc """
  Parses the command line and prints a table of the first or last _n_ issues
  of a GitHub `project`.

  `argv` can be "-h" or "--help", which prints info on the command's
  usage and syntax. Otherwise it contains a `user`, a `project`, and
  optionally the number of issues to format (the first _n_ ones).
  To format the last _n_ issues, specify switch `--last`.
  To ring the bell, specify switch `--bell`.
  To choose a table style, specify switch `--table-style`.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help`        - for help
    - `-l` or `--last`        - to format the last _n_ issues
    - `-b` or `--bell`        - to ring the bell
    - `-t` or `--table-style` - to choose a table style

  ## Table styles

  #{Style.texts("\s\s- `&arg`&filler - &note\n")}
  """
  @spec main([String.t()]) :: :ok | no_return
  def main(argv) do
    case parse(argv) do
      {user, project, count, bell, style} ->
        case Issues.fetch(user, project) do
          {:ok, issues} ->
            :ok = printing(user, project) |> IO.ANSI.format() |> IO.puts()
            :ok = Log.info(:printing, {user, project, __ENV__})
            options = [count: count, bell: bell, style: style]
            :ok = Table.write(issues, @table_spec, options)

          {:error, text} ->
            :ok = error(user, project, text) |> IO.ANSI.format() |> IO.puts()
            :ok = Log.error(:fetching, {text, user, project})
            System.stop(1)
        end

      :help ->
        :ok = Help.show_help()
        System.stop(0)
    end
  end

  ## Private functions

  @spec printing(user, project) :: IO.ANSI.ansilist()
  defp printing(user, project) do
    [
      @table_spec.left_margin,
      [:light_green, "Printing issues from GitHub "],
      [:italic, "#{user}/#{project}..."]
    ]
  end

  @spec error(user, project, String.t()) :: IO.ANSI.ansilist()
  defp error(user, project, text) do
    [
      [:light_green, "Error fetching issues from GitHub "],
      [:italic, "#{user}/#{project}...\n"],
      [:light_yellow, text]
    ]
  end

  # @doc """
  # Parses `argv` (command line arguments). Returns either
  # a tuple of `{user, project, count, bell, table_style}` or `:help`.

  # ## Examples

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["-h"])
  #     :help

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["user", "project", "99"])
  #     {"user", "project", 99, false, :medium}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["user", "project", "88", "--last", "--bell"])
  #     {"user", "project", -88, true, :medium}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["user", "project", "6", "--table-style", "dark"])
  #     {"user", "project", 6, false, :dark}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["user", "project", "6", "-blt", "dark-alt"])
  #     {"user", "project", -6, true, :dark_alt}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.parse(["user", "project", "0", "--table-style", "dark"])
  #     :help
  # """
  @spec parse([String.t()]) :: parsed
  defp parse(argv) do
    argv
    |> OptionParser.parse(strict: @strict, aliases: @aliases)
    |> to_parsed()
  end

  # @doc """
  # Converts the output of `OptionParser.parse/2` to `parsed`.

  # ## Examples

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_parsed({[help: true], [], []})
  #     :help

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_parsed({[help: true], ["anything"], []})
  #     :help

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_parsed({[], ["user", "project", "13"], []})
  #     {"user", "project", 13, false, :medium}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_parsed({[], ["user", "project"], []})
  #     {"user", "project", 9, false, :medium}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_parsed({
  #     ...>   [last: true, bell: true, table_style: "dark-alt"],
  #     ...>   ["user", "project", "13"],
  #     ...>   []
  #     ...> })
  #     {"user", "project", -13, true, :dark_alt}
  # """
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

  # @doc """
  # Converts `args` to a tuple or `:error`.

  # ## Examples

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_tuple(["user", "project", "7"])
  #     {"user", "project", 7}

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_tuple(["user", "project", "0"])
  #     :error

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_tuple([])
  #     :error

  #     iex> alias GitHub.Issues.CLI
  #     iex> CLI.to_tuple(["user", "project"])
  #     {"user", "project", 9}
  # """
  @spec to_tuple([String.t()]) :: {user, project, pos_integer} | :error
  defp to_tuple([user, project, count] = _args) do
    with {int, ""} when int > 0 <- Integer.parse(count),
         do: {user, project, int},
         else: (_ -> :error)
  end

  defp to_tuple([user, project] = _args), do: {user, project, @count}
  defp to_tuple(_), do: :error
end
