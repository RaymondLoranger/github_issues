defmodule GitHub.Issues.CLITest do
  use ExUnit.Case, async: true
  use PersistConfig

  alias GitHub.Issues.CLI

  doctest CLI

  @count Application.get_env(@app, :default_count)

  describe "CLI.parse/1" do
    test "returns :help with arguments -h or --help" do
      assert CLI.parse(["-h"]) == :help
      assert CLI.parse(["-h", "anything"]) == :help
      assert CLI.parse(["anything", "-h"]) == :help
      assert CLI.parse(["user", "project", "--help"]) == :help
    end

    test "returns 5 values if 3 given" do
      assert CLI.parse(["user", "project", "99"]) ==
               {"user", "project", 99, false, :medium}
    end

    test "defaults count if not given" do
      assert CLI.parse(["user", "project"]) ==
               {"user", "project", @count, false, :medium}

      assert CLI.parse(["user", "project", "--last"]) ==
               {"user", "project", -@count, false, :medium}
    end

    test "returns 5 values if 4 given" do
      assert CLI.parse(["user", "project", "99", "--last"]) ==
               {"user", "project", -99, false, :medium}

      assert CLI.parse(["user", "project", "--last", "99"]) ==
               {"user", "project", -99, false, :medium}
    end

    test "returns 5 values if count is zero" do
      assert CLI.parse(["user", "project", "0"]) ==
               {"user", "project", 0, false, :medium}

      assert CLI.parse(["user", "project", "0", "--last"]) ==
               {"user", "project", 0, false, :medium}

      assert CLI.parse(["user", "project", "-0"]) ==
               {"user", "project", 0, false, :medium}
    end

    test "returns :help if count not positive integer" do
      assert CLI.parse(["user", "project", "nine"]) == :help
      assert CLI.parse(["user", "project", "-999"]) == :help
      assert CLI.parse(["user", "project", "--bell", "-999"]) == :help
    end

    test "returns :help if table style invalid" do
      assert CLI.parse(["user", "project", "-t", "DARK"]) == :help
      assert CLI.parse(["user", "project", "-t", "Dark"]) == :help
    end
  end
end
