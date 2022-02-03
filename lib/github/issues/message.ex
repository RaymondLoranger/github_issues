defmodule GitHub.Issues.Message do
  use PersistConfig

  alias GitHub.Issues.CLI

  @table_spec get_env(:table_spec)

  @spec status(pos_integer) :: String.t()
  def status(301), do: "status code 301 ⇒ Moved Permanently"
  def status(302), do: "status code 302 ⇒ Found"
  def status(403), do: "status code 403 ⇒ Forbidden"
  def status(404), do: "status code 404 ⇒ Not Found"
  def status(code), do: "status code #{code}"

  @spec error(term) :: String.t()
  def error(reason), do: "reason => #{inspect(reason)}"

  @spec writing_table(CLI.user(), CLI.project()) :: :ok
  def writing_table(user, project) do
    [
      @table_spec.left_margin,
      [:white, "Writing table of issues from GitHub "],
      [:light_white, "#{user}/#{project}..."]
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  @spec fetching_error(CLI.user(), CLI.project(), String.t()) :: :ok
  def fetching_error(user, project, text) do
    [
      [:white, "Error fetching issues from GitHub "],
      [:light_white, "#{user}/#{project}...\n"],
      [:light_yellow, :string.titlecase(text)]
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
