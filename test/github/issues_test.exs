
defmodule GitHub.IssuesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias GitHub.Issues

  doctest Issues

  setup_all do
    Logger.configure level: :error # prevents info messages
  end

  describe "GitHub.Issues.fetch/3" do
    test ~S[error "reason: :econnrefused" if bad url given] do
      assert Issues.fetch("any", "any", url_template: "http://localhost:1")
      == {:error, "reason: :econnrefused"}
    end

    test ~S[error "reason: :nxdomain" if bad url given] do
      assert Issues.fetch(
        "elixir-lang", "elixir",
        url_template: "https://api.github.org/repos/{user}/{project}/issues"
      ) == {:error, "reason: :nxdomain"}
    end

    test ~S[error "status code: 301 (not found)" if bad url given?] do
      assert Issues.fetch(
        "elixir-lang", "elixir",
        url_template: "http://api.github.com/repos/<user>/<project>/issues"
      ) in [
        error: "status code: 301 (not found)",
        error: "reason: :connect_timeout"
      ]
    end

    test ~S[error "status code: 404 (not found)" if bad url given?] do
      assert Issues.fetch(
        "any", "any", url_template: "https://api.github.com/what"
      ) in [
        error: "status code: 404 (not found)",
        error: "reason: :connect_timeout"
      ]
    end

    test ~S[error "exception: argument error" if bad url given] do
      assert Issues.fetch(
        "any", "any", url_template: "htps:/api.github.com/what"
      ) == {:error, "exception: argument error"}
    end
  end
end
