# ┌───────────────────────────────────────────────────────────┐
# │ Inspired by the book "Programming Elixir" by Dave Thomas. │
# └───────────────────────────────────────────────────────────┘
defmodule GitHub.Issues do
  @moduledoc """
  Fetches a list of issues from a GitHub project.
  """

  use PersistConfig

  alias __MODULE__.{CLI, Log, Message, URLTemplate}

  @url_template get_env(:url_template)

  @typedoc "GitHub issue"
  @type issue :: map

  @doc """
  Fetches issues from the GitHub `project` of a given `user`.
  
  Returns a tuple of either `{:ok, [issue]}` or `{:error, text}`.
  
  ## Examples
  
      iex> alias GitHub.Issues
      iex> {:ok, issues} = Issues.fetch("opendrops", "passport")
      iex> Enum.all?(issues, &is_map/1) and length(issues) > 0
      true
  """
  @spec fetch(CLI.user(), CLI.project()) ::
          {:ok, [issue]} | {:error, String.t()}
  def fetch(user, project) do
    url = URLTemplate.url(user, project, @url_template)
    :ok = Log.info(:fetching_issues, {user, project, url, __ENV__})

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, :jsx.decode(body, [:return_maps])}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, Message.status(code)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Message.error(reason)}
    end
  end
end
