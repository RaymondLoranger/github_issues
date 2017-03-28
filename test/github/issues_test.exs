
defmodule GitHub.IssuesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias GitHub.Issues

  doctest Issues

  setup_all do
    Logger.configure level: :error # prevents info logging
  end

  describe "GitHub.Issues.fetch/3" do
    test "returns {:error, :econnrefused} if bad url given" do
      assert Issues.fetch("any", "any", url_template: "http://localhost:1")
      == {:error, :econnrefused}
    end

    test "returns {:error, :nxdomain} if bad url given" do
      assert Issues.fetch(
        "elixir-lang", "elixir",
        url_template: "https://api.github.org/repos/{user}/{project}/issues"
      ) == {:error, :nxdomain}
    end

    test ~s/may return {:error, "301 not found"} if bad url given/ do
      assert Issues.fetch(
        "elixir-lang", "elixir",
        url_template: "http://api.github.com/repos/<user>/<project>/issues"
      ) in [{:error, "301 not found"}, {:error, :connect_timeout}]
    end

    test ~s/may return {:error, "404 not found"} if bad url given/ do
      assert Issues.fetch(
        "any", "any", url_template: "https://api.github.com/what"
      ) in [{:error, "404 not found"}, {:error, :connect_timeout}]
    end

    test ~s/returns {:error, "argument error"} if bad url given/ do
      assert Issues.fetch(
        "any", "any", url_template: "htps:/api.github.com/what"
      ) == {:error, "argument error"}
    end
  end
end
