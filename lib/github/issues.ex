
# Based on the book "Programming Elixir" by Dave Thomas.

defmodule GitHub.Issues do
  @moduledoc """
  Fetches a list of issues from a GitHub project.
  """

  @app          Mix.Project.config[:app]
  @url_template Application.get_env(@app, :url_template)

  @doc """
  Fetches issues from a GitHub `project` of a given `user`.

  Returns a tuple of either `{:ok, [issues]}` or `{:error, reason}`.

  ## Parameters

    - `user`    - GitHub user
    - `project` - GitHub project
    - `options` - URL template (keyword)

  ## Options

    - `:url_template` - defaults to config value `:url_template`

  ## Examples

      alias GitHub.Issues
      Issues.fetch("laravel", "elixir")

      alias GitHub.Issues
      Issues.fetch("dynamo", "dynamo")
  """
  @spec fetch(String.t, String.t, Keyword.t) :: {:ok, [map]} | {:error, any}
  def fetch(user, project, options \\ []) do
    require Logger
    Logger.info(
      "Fetching GitHub Issues from project #{project} of user #{user}..."
    )
    try do
      with url_template <- Keyword.get(options, :url_template, @url_template),
          url <- url(url_template, user, project),
          {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url) do
        {:ok, :jsx.decode(body, [:return_maps])}
      else
        {:ok, %{status_code: 301}} -> {:error, "301 not found"}
        {:ok, %{status_code: 404}} -> {:error, "404 not found"}
        {:error, %{reason: reason}} -> {:error, reason}
        any -> {:error, any}
      end
    rescue
      error -> {:error, Exception.message error}
    end
  end

  @doc """
  Returns a URL based on `user` and `project`.

  ## Parameters

    - `url_template` - URL template
    - `user`         - user
    - `project`      - project

  ## Examples

      iex> alias GitHub.Issues
      iex> app = Mix.Project.config[:app]
      iex> url_template = Application.get_env(app, :url_template)
      iex> Issues.url(url_template, "laravel", "elixir")
      "https://api.github.com/repos/laravel/elixir/issues"

      iex> alias GitHub.Issues
      iex> url_template = "elixir-lang.org/<project>/{user}/wow"
      iex> Issues.url(url_template, "José", "Elixir")
      "elixir-lang.org/Elixir/José/wow"
  """
  @spec url(String.t, String.t, String.t) :: String.t
  def url(url_template, user, project) do
    url_template
    |> String.replace(~r/{user}|<user>/, user)
    |> String.replace(~r/{project}|<project>/, project)
  end
end
