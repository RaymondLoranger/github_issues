# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues do
  # @moduledoc """
  # Fetches a list of issues from a GitHub project.
  # """
  @moduledoc false

  use PersistConfig

  alias GitHub.Issues.CLI

  require Logger

  @typep issue :: map

  @url_template Application.get_env(@app, :url_template)

  @doc """
  Fetches issues from a GitHub `project` of a given `user`.

  Returns a tuple of either `{:ok, [issue]}` or `{:error, text}`.

  ## Parameters

    - `user`         - GitHub user
    - `project`      - GitHub project
    - `url_template` - URL template

  ## Examples

      alias GitHub.Issues
      Issues.fetch("laravel", "elixir")
  """
  @spec fetch(CLI.user, CLI.project, String.t) ::
          {:ok, [issue]} | {:error, String.t}
  def fetch(user, project, url_template \\ @url_template) do
    Logger.info("Fetching GitHub Issues from #{user}/#{project}...")
    try do
      with url <- url(url_template, user, project),
           {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url) do
        {:ok, :jsx.decode(body, [:return_maps])}
      else
        {:ok, %{status_code: 301}} -> {:error, "status code: 301 (not found)"}
        {:ok, %{status_code: 404}} -> {:error, "status code: 404 (not found)"}
        {:error, %{reason: reason}} -> {:error, "reason: #{inspect reason}"}
      end
    rescue
      error -> {:error, "exception: #{Exception.message(error)}"}
    end
  end

  ## Private functions

  # @doc """
  # Returns a URL based on `user` and `project`.

  # ## Parameters

  #   - `url_template` - URL template
  #   - `user`         - user
  #   - `project`      - project

  # ## Examples

  #     iex> alias GitHub.Issues
  #     iex> app = Mix.Project.config[:app]
  #     iex> url_template = Application.get_env app, :url_template
  #     iex> Issues.url url_template, "laravel", "elixir"
  #     "https://api.github.com/repos/laravel/elixir/issues"

  #     iex> alias GitHub.Issues
  #     iex> url_template = "elixir-lang.org/<project>/{user}/wow"
  #     iex> Issues.url url_template, "José", "Elixir"
  #     "elixir-lang.org/Elixir/José/wow"
  # """
  @spec url(String.t, CLI.user, CLI.project) :: String.t
  defp url(url_template, user, project) do
    url_template
    |> String.replace(~r/{user}|<user>/, user)
    |> String.replace(~r/{project}|<project>/, project)
  end
end
