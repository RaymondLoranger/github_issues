defmodule GitHub.IssuesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias GitHub.Issues

  doctest Issues

  setup_all do
    # prevents info messages
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
    end

    test ~S[error "status code: 301 (not found)" if bad url given?] do
      url = "http://api.github.com/repos/<user>/<project>/issues"

      assert Issues.fetch("elixir-lang", "elixir", url) ==
               {:error, "status code: 301 (not found)"}
    end

    test ~S[error "status code: 404 (not found)" if bad url given?] do
      url = "https://api.github.com/what"

      assert Issues.fetch("any", "any", url) ==
               {:error, "status code: 404 (not found)"}
    end

    test ~S[error "exception: argument error" if bad url given] do
      url = "htps:/api.github.com/what"

      assert Issues.fetch("any", "any", url) in [
               error: "exception: argument error",
               error: "reason: :nxdomain"
             ]
    end
  end
end
