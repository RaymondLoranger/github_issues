defmodule GitHub.IssuesTest do
  use ExUnit.Case, async: true

  alias GitHub.Issues

  doctest Issues

  setup_all do
    # Prevents info messages...
    Logger.configure(level: :error)
  end

  describe "Issues.fetch/2" do
    test ~S[error "reason: :econnrefused" if bad url given] do
      url = "http://localhost:1"

      assert Issues.fetch("any", "any", url) ==
               {:error, "reason: :econnrefused"}
    end

    test ~S[error "reason: :nxdomain" if bad url given] do
      url = "https://api.github.org/repos/{user}/{project}/issues"

      assert Issues.fetch("elixir-lang", "elixir", url) ==
               {:error, "reason: :nxdomain"}

      url = "htps:/api.github.com/what"

      assert Issues.fetch("any", "any", url) == {:error, "reason: :nxdomain"}
    end

    test ~S[error "status code: 301 Moved Permanently" if bad url given] do
      url = "http://api.github.com/repos/<user>/<project>/issues"

      assert Issues.fetch("elixir-lang", "elixir", url) ==
               {:error, "status code: 301 ⇒ Moved Permanently"}
    end

    test ~S[error "status code: 404 Not Found" if bad url given] do
      url = "https://api.github.com/what"

      assert Issues.fetch("any", "any", url) ==
               {:error, "status code: 404 ⇒ Not Found"}
    end
  end
end
