defmodule GitHub.Issues.Log do
  use File.Only.Logger

  error :fetching_error, {user, project, text, env} do
    """
    \nError fetching issues from GitHub...
    • Error: #{text}
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  info :writing_table, {user, project, env} do
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
end
