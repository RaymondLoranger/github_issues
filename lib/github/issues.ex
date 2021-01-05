# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues do
  @moduledoc """
  Fetches a list of issues from a GitHub project.
  """

  use PersistConfig

  alias __MODULE__.{CLI, Log}

  @url_template get_env(:url_template)

  @type issue :: map

  @doc """
  Fetches issues from a GitHub `project` of a given `user`.

  Returns a tuple of either `{:ok, [issue]}` or `{:error, text}`.

  ## Parameters

    - `user`         - GitHub user
    - `project`      - GitHub project
    - `url_template` - URL template (EEx sting)

  ## Examples

      iex> alias GitHub.Issues
      iex> {:ok, issues} = Issues.fetch("opendrops", "passport")
      iex> Enum.all?(issues, &is_map/1) and length(issues) > 0
      true
  """
  @spec fetch(CLI.user(), CLI.project(), String.t()) ::
          {:ok, [issue]} | {:error, String.t()}
  def fetch(user, project, url_template \\ @url_template) do
    url = url(user, project, url_template)
    :ok = Log.info(:fetching, {user, project, url, __ENV__})

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, :jsx.decode(body, [:return_maps])}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, status(code)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, error(reason)}
    end
  end

  ## Private functions

  @spec status(pos_integer) :: String.t()
  defp status(301), do: "status code 301 ⇒ Moved Permanently"
  defp status(302), do: "status code 302 ⇒ Found"
  defp status(403), do: "status code 403 ⇒ Forbidden"
  defp status(404), do: "status code 404 ⇒ Not Found"
  defp status(code), do: "status code #{code}"

  @spec error(term) :: String.t()
  defp error(reason), do: "reason => #{inspect(reason)}"

  # @doc """
  # Returns a URL based on `user`, `project` and `url_template`.

  # ## Parameters

  #   - `user`         - user
  #   - `project`      - project
  #   - `url_template` - URL template (EEx string)

  # ## Examples

  #     iex> alias GitHub.Issues
  #     iex> url_template = "api.github.com/repos/<%=user%>/<%=project%>/issues"
  #     iex> Issues.url("opendrops", "passport", url_template)
  #     "api.github.com/repos/opendrops/passport/issues"

  #     iex> alias GitHub.Issues
  #     iex> url_template = "elixir-lang.org/<%=project%>/<%=user%>/wow"
  #     iex> Issues.url("José", "Elixir", url_template)
  #     "elixir-lang.org/Elixir/José/wow"

  #     iex> alias GitHub.Issues
  #     iex> url_template = "elixir-lang.org/<project>/<user>/wow"
  #     iex> Issues.url("José", "Elixir", url_template)
  #     "elixir-lang.org/<project>/<user>/wow"
  # """
  @spec url(CLI.user(), CLI.project(), String.t()) :: String.t()
  defp url(user, project, url_template) do
    EEx.eval_string(url_template, user: user, project: project)
  end
end
