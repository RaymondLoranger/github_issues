defmodule GitHub.Issues.URLTemplate do
  @moduledoc """
  Returns a URL based on a user, a project and a URL template.
  """

  alias GitHub.Issues.CLI

  @doc """
  Returns a URL based on `user`, `project` and `url_template`.
  
  ## Parameters
  
    - `user`         - user
    - `project`      - project
    - `url_template` - URL template (EEx string)
  
  ## Examples
  
      iex> alias GitHub.Issues
      iex> url_template = "api.github.com/repos/<%=user%>/<%=project%>/issues"
      iex> Issues.url("opendrops", "passport", url_template)
      "api.github.com/repos/opendrops/passport/issues"
  
      iex> alias GitHub.Issues
      iex> url_template = "elixir-lang.org/<%=project%>/<%=user%>/wow"
      iex> Issues.url("José", "Elixir", url_template)
      "elixir-lang.org/Elixir/José/wow"
  
      iex> alias GitHub.Issues
      iex> url_template = "elixir-lang.org/<project>/<user>/wow"
      iex> Issues.url("José", "Elixir", url_template)
      "elixir-lang.org/<project>/<user>/wow"
  """
  @spec url(CLI.user(), CLI.project(), String.t()) :: String.t()
  def url(user, project, url_template) do
    EEx.eval_string(url_template, user: user, project: project)
  end
end
