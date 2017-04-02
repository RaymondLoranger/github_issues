
# Based on the book "Programming Elixir" by Dave Thomas.

defmodule GitHub.Issues.CLI do
  @moduledoc """
  Handles the command line parsing and the dispatch to
  the various functions that end up generating a table
  of the first or last _n_ issues of a GitHub project.
  """

  alias GitHub.Issues
  alias IO.ANSI.Table.Formatter
  alias IO.ANSI.Table.Style

  @type parsed :: {String.t, String.t, integer, boolean, atom} | :help

  @app      Mix.Project.config[:app]
  @aliases  Application.get_env(@app, :aliases)
  @count    Application.get_env(@app, :default_count)
  @escript  Mix.Local.name_for(:escript, Mix.Project.config)
  @strict   Application.get_env(@app, :strict)
  @switches Application.get_env(@app, :default_switches)

  @doc """
  Parses and processes the command line arguments.

  ## Parameters

    - `argv` - command line arguments (list)
  """
  @spec main([String.t]) :: :ok | no_return
  def main(argv) do
    with {user, project, count, bell, style} <- parse(argv),
        {:ok, issues} <- Issues.fetch(user, project) do
      Formatter.print_table(issues, count, bell, style)
    else
      :help -> help()
      {:error, text} -> report_error(text)
    end
  end

  @spec report_error(String.t) :: no_return
  defp report_error(text) do
    IO.puts "Error fetching from GitHub - #{text}"
    System.halt(2)
  end

  @spec help :: no_return
  defp help do
    # Examples of usage on Windows:
    #   escript gi --help
    #   escript gi elixir-lang elixir 7 --last
    #   escript gi myfreeweb httpotion --bell
    #   escript gi dynamo dynamo -lb 8 -t GREEN
    #   escript gi dynamo dynamo -bl 9 --table-style=dark
    #   escript gi dynamo dynamo 11 -blt light
    # Examples of usage on macOS:
    #   ./gi laravel elixir
    prefix = case :os.type do
      {:win32, _} -> "usage: escript #{@escript}"
      ___________ -> "usage: ./#{@escript}"
    end
    filler = String.duplicate "\s", String.length(prefix)
    line_1 = "[(-h | --help)] <github-user> <github-project>"
    line_2 = "[(-l | --last)] <count> [(-b | --bell)]"
    line_3 = "[(-t | --table-style)=<table-style>]"
    IO.write """
      #{prefix} #{line_1}
      #{filler} #{line_2}
      #{filler} #{line_3}
      where:
        - default <count> is #{@count}
        - default <table-style> is #{@switches[:table_style]}
        - <table-style> is one of:
      """
    Style.texts "\s\s\s\s• &tag&filler - &note", &IO.puts/1
    System.halt(0)
  end

  @doc """
  Parses the command line arguments.

  `argv` can be `-h` or `--help`, which returns `:help`. Otherwise
  it is a GitHub user name, project name, and optionally the number
  of issues to format (the first _n_ ones). To format the last _n_
  issues, specify switch `--last` which will return a negative count.

  Returns either a tuple of `{user, project, count, bell, style}`
  or `:help` if `--help` was given.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help`        - for help
    - `-l` or `--last`        - to format the last _n_ issues
    - `-b` or `--bell`        - to ring the bell
    - `-t` or `--table-style` - to apply a specific table style

  ## Table styles

  #{Style.texts "\s\s- `&tag`&filler - &note\n"}
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
  @spec parse([String.t]) :: parsed
  def parse(argv) do
    argv
    |> OptionParser.parse(strict: @strict, aliases: @aliases)
    |> reformat
  end

  @spec reformat({Keyword.t, [String.t], [tuple]}) :: parsed
  defp reformat({switches, args, []}) do
    with {user, project, count} <- normalize(args),
        %{
          help: false, last: last, bell: bell, table_style: table_style
        } <- Map.merge(Map.new(@switches), Map.new(switches)),
        {:ok, style} <- Style.style_for(table_style) do
      {user, project, last && -count || count, bell, style}
    else
      _ -> :help
    end
  end
  defp reformat(_), do: :help

  @spec normalize([String.t]) :: {String.t, String.t, non_neg_integer} | :error
  defp normalize([user, project, count]) do
    with {int, ""} when int >= 0 <- Integer.parse(count) do
      {user, project, int}
    else
      _ -> :error
    end
  end
  defp normalize([user, project]), do: {user, project, @count}
  defp normalize(_), do: :error
end
