defmodule GitHub.Issues.Help do
  @moduledoc """
  Prints info on the command's usage and syntax.
  """
  use PersistConfig

  alias IO.ANSI.Table.Style

  @count get_env(:default_count)
  @escript Mix.Project.config()[:escript][:name]
  @help_attrs get_env(:help_attrs)
  @switches get_env(:default_switches)

  @doc """
  Prints info on the command's usage and syntax.
  """
  @spec show_help() :: :ok
  def show_help() do
    # Examples of usage on Windows:
    #   escript gi --help
    #   escript gi elixir-lang elixir 7 --last
    #   escript gi myfreeweb httpotion --bell
    #   escript gi dynamo dynamo -lb 8 -t green-border
    #   escript gi dynamo dynamo -bl 9 --table-style=dark
    #   escript gi dynamo dynamo 11 -blt light
    # Examples of usage on macOS:
    #   ./gi dynamo dynamo
    {types, texts} =
      case :os.type() do
        {:win32, _} ->
          {[:section, :normal, :command, :normal],
           ["usage:", " ", "escript", " #{@escript}"]}

        {:unix, _} ->
          {[:section, :normal], ["usage:", " ./#{@escript}"]}
      end

    filler = String.duplicate("", Enum.join(texts) |> String.length())
    prefix = help_format(types, texts)

    line_user_project =
      help_format([:switch, :arg, :normal, :arg], [
        "[(-h | --help)] ",
        "<github-user>",
        " ",
        "<github-project>"
      ])

    line_count =
      help_format([:switch, :normal, :arg, :normal, :switch], [
        "[(-l | --last)]",
        " ",
        "<count>",
        " ",
        "[(-b | --bell)]"
      ])

    line_table_style =
      help_format([:switch, :arg, :switch], [
        "[(-t | --table-style)=",
        "<table-style>",
        "]"
      ])

    line_where = help_format([:section], ["where:"])

    line_default_count =
      help_format([:normal, :arg, :normal, :value], [
        "  - default ",
        "<count>",
        " is ",
        "#{@count}"
      ])

    line_default_table_style =
      help_format([:normal, :arg, :normal, :value], [
        "  - default ",
        "<table-style>",
        " is ",
        "#{@switches[:table_style]}"
      ])

    line_table_style_one_of =
      help_format([:normal, :arg, :normal], [
        "  - ",
        "<table-style>",
        " is one of:"
      ])

    IO.write("""
    #{prefix} #{line_user_project}
    #{filler} #{line_count}
    #{filler} #{line_table_style}
    #{line_where}
    #{line_default_count}
    #{line_default_table_style}
    #{line_table_style_one_of}
    """)

    template =
      help_format([:normal, :value, :normal], [
        "\s\s\s\s• ",
        "&arg",
        "&filler - &note"
      ])

    texts = Style.texts("#{template}")
    Enum.each(texts, &IO.puts/1)
  end

  @spec help_format([atom], [String.t()]) :: IO.ANSI.ansidata()
  defp help_format(types, texts) do
    Enum.map(types, &@help_attrs[&1])
    |> Enum.zip(texts)
    |> Enum.map(&Tuple.to_list/1)
    |> IO.ANSI.format()
  end
end
