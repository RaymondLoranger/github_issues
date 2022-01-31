defmodule GitHub.Issues.Log do
  use File.Only.Logger
  use PersistConfig

  alias GitHub.Issues.CLI

  @table_spec get_env(:table_spec)

  error :fetching_error, {user, project, text, env} do
    :ok = fetching_error(user, project, text)

    """
    \nError fetching issues from GitHub...
    • Error: #{text}
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  info :writing_table, {user, project, env} do
    :ok = writing_table(user, project)

    """
    \nWriting table of issues from GitHub...
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  info :fetching_issues, {user, project, url, env} do
    """
    \nFetching issues from GitHub...
    • URL: #{url}
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  ## Private functions

  @spec writing_table(CLI.user(), CLI.project()) :: :ok
  defp writing_table(user, project) do
    [
      @table_spec.left_margin,
      [:white, "Writing table of issues from GitHub "],
      [:light_white, "#{user}/#{project}..."]
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  @spec fetching_error(CLI.user(), CLI.project(), String.t()) :: :ok
  defp fetching_error(user, project, text) do
    [
      [:white, "Error fetching issues from GitHub "],
      [:light_white, "#{user}/#{project}...\n"],
      [:light_yellow, :string.titlecase(text)]
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
