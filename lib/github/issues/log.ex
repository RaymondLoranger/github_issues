defmodule GitHub.Issues.Log do
  use File.Only.Logger

  error :fetching, {text, user, project} do
    """
    \nError fetching issues from GitHub...
    • Error: #{text}
    • User: #{user}
    • Project: #{project}
    #{from()}
    """
  end

  info :printing, {user, project, env} do
    """
    \nPrinting issues from GitHub...
    • Inside function:
      #{fun(env)}
    • User: #{user}
    • Project: #{project}
    #{from()}
    """
  end

  info :fetching, {user, project, url, env} do
    """
    \nFetching issues from GitHub...
    • Inside function:
      #{fun(env)}
    • URL: #{url}
    • User: #{user}
    • Project: #{project}
    #{from()}
    """
  end
end
