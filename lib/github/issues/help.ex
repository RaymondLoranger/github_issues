defmodule GitHub.Issues.Help do
  @moduledoc """
  Prints info on the escript command's usage and syntax.
  """

  use PersistConfig

  alias IO.ANSI.Table.Style

  @count get_env(:default_count)
  @escript Mix.Project.config()[:escript][:name]
  @help_attrs get_env(:help_attrs)
  @switches get_env(:default_switches)

  @doc """
  Prints info on the escript command's usage and syntax.
  """
  @spec show_help() :: :ok
  def show_help() do
    # Examples of usage:
    #   gi --help
    #   gi elixir-lang elixir 7 --last
    #   gi myfreeweb httpotion --bell
    #   gi dynamo dynamo -lb 8 -t green-border
    #   gi dynamo dynamo -bl 9 --table-style=dark
    #   gi dynamo dynamo 11 -blt light
    #   gi dynamo dynamo
    texts = ["usage:", " #{@escript}"]
    filler = String.pad_leading("", Enum.join(texts) |> String.length())
    prefix = help_format([:section, :normal], texts)

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

  ## Private functions

  @spec help_format([atom], [String.t()]) :: IO.chardata()
  defp help_format(types, texts) do
    types
    |> Enum.map(&@help_attrs[&1])
    |> Enum.zip(texts)
    |> Enum.map(&Tuple.to_list/1)
    |> IO.ANSI.format()
  end
end
