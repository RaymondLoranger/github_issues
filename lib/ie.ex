
defmodule IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   require IE
  #   IE.use

  defmacro use do
    quote do
      alias GitHub.{Issues, Issues.CLI}
      :ok
    end
  end
end
