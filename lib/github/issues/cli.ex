
# Based on the book "Programming Elixir" by Dave Thomas.

defmodule GitHub.Issues.CLI do
  @moduledoc """
  Handles the command line parsing and the dispatch to
  the various functions that end up generating a table
  of the first or last _n_ issues of a GitHub project.
  """

  import Logger, only: [error: 1]

  alias GitHub.Issues
  alias IO.ANSI.Table.{Formatter, Style}

  @type parsed :: {String.t, String.t, integer, boolean, atom} | :help

  @app        Mix.Project.config[:app]
  @aliases    Application.get_env(@app, :aliases)
  @count      Application.get_env(@app, :default_count)
  @escript    Mix.Local.name_for(:escript, Mix.Project.config)
  @help_attrs Application.get_env(@app, :help_attrs)
  @strict     Application.get_env(@app, :strict)
  @switches   Application.get_env(@app, :default_switches)

  @doc """
  Parses and processes the command line arguments.

  ## Parameters

    - `argv` - command line arguments (list)
  """
  @spec main([String.t]) :: :ok | no_return
  def main(argv) do
    with {user, project, count, bell, style} <- parse(argv),
      {:ok, issues} <- Issues.fetch(user, project)
    do
      Formatter.print_table(issues, count, bell, style)
    else
      :help -> help()
      {:error, text} -> log_error(text)
    end
  end

  @spec log_error(String.t) :: no_return
  defp log_error(text) do
    error "Error fetching from GitHub - #{text}"
    Process.sleep(1_000) # ensure message logged before exiting
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
    {types, texts} = case :os.type do
      {:win32, _} ->
        { [:section, :normal, :command, :normal],
          ["usage:", " ", "escript", " #{@escript}"]
        }
      _ -> # e.g. {:unix, _}
        { [:section, :normal],
          ["usage:", " ./#{@escript}"]
        }
    end
    filler = String.duplicate " ", String.length Enum.join(texts)
    prefix = help_format(types, texts)
    line_1 = help_format(
      [:switch, :arg, :normal, :arg],
      ["[(-h | --help)] ", "<github-user>", " ", "<github-project>"]
    )
    line_2 = help_format(
      [:switch, :normal, :arg, :normal, :switch],
      ["[(-l | --last)]", " ", "<count>", " ", "[(-b | --bell)]"]
    )
    line_3 = help_format(
      [:switch, :arg, :switch],
      ["[(-t | --table-style)=", "<table-style>", "]"]
    )
    line_4 = help_format(
      [:section],
      ["where:"]
    )
    line_5 = help_format(
      [:normal, :arg, :normal],
      ["  - default ", "<count>", " is #{@count}"]
    )
    line_6 = help_format(
      [:normal, :arg, :normal, :value],
      ["  - default ", "<table-style>", " is ", "#{@switches[:table_style]}"]
    )
    line_7 = help_format(
      [:normal, :arg, :normal],
      ["  - ", "<table-style>", " is one of:"]
    )
    IO.write """
      #{prefix} #{line_1}
      #{filler} #{line_2}
      #{filler} #{line_3}
      #{line_4}
      #{line_5}
      #{line_6}
      #{line_7}
      """
    template = help_format(
      [:normal, :value, :normal],
      ["\s\s\s\s• ", "&tag", "&filler - &note"]
    )
    Style.texts "#{template}", &IO.puts/1
    System.halt(0)
  end

  @spec help_format([atom], [String.t]) :: maybe_improper_list
  defp help_format(types, texts) do
    types
    |> Enum.map(&@help_attrs[&1])
    |> Enum.zip(texts)
    |> Enum.map(&Tuple.to_list/1)
    |> IO.ANSI.format
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
      %{help: false, last: last, bell: bell, table_style: table_style}
      <- Map.merge(Map.new(@switches), Map.new(switches)),
      {:ok, style} <- Style.style_for(table_style)
    do
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
