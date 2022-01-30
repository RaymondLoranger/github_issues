defmodule GitHub.Issues.Log do
  use File.Only.Logger

  error :fetching, {text, user, project, env} do
    """
    \nError fetching issues from GitHub...
    • Error: #{text}
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  info :printing, {user, project, env} do
    """
    \nPrinting issues from GitHub...
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end

  info :fetching, {user, project, url, env} do
    """
    \nFetching issues from GitHub...
    • URL: #{url}
    • User: #{user}
    • Project: #{project}
    #{from(env, __MODULE__)}
    """
  end
end
