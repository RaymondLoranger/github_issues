defmodule GitHub.IssuesTest do
  use ExUnit.Case, async: true

  alias GitHub.Issues

  doctest Issues

  describe "Issues.fetch/3" do
    test ~S[error `:econnrefused` if bad url template given] do
      assert Issues.fetch("user", "project", "http://localhost:1") ==
               {:error, "reason => :econnrefused"}
    end

    test ~S[error `:nxdomain` if bad url template given] do
      url_template = "api.github.org/repos/<%=user%>/<%=project%>/issues"

      assert Issues.fetch("elixir-lang", "elixir", url_template) ==
               {:error, "reason => :nxdomain"}

      url_template = "htps:/api.github.com/what"

      assert Issues.fetch("any", "any", url_template) ==
               {:error, "reason => :nxdomain"}
    end

    test ~S[error `status code 301` if bad url template given] do
      url_template = "http://api.github.com/repos/<%=user%>/<%=project%>/issues"

      assert Issues.fetch("elixir-lang", "elixir", url_template) ==
               {:error, "status code 301 ⇒ Moved Permanently"}
    end

    test ~S[error `status code 404 or 403` if bad url template given] do
      url_template = "https://api.github.com/what"

      assert Issues.fetch("user", "project", url_template) in [
               {:error, "status code 404 ⇒ Not Found"},
               {:error, "status code 403 ⇒ Forbidden"}
             ]
    end
  end
end
