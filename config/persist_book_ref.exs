use Mix.Config

config :github_issues,
  book_ref:
    """
    Inspired by the book [Programming Elixir]
    (https://pragprog.com/book/elixir16/
    programming-elixir-1-6) by Dave Thomas.
    """
    |> String.replace("\n", "")
