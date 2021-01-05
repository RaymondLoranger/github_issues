# GitHub Issues

[![Build Status](https://travis-ci.org/RaymondLoranger/github_issues.svg?branch=master)](https://travis-ci.org/RaymondLoranger/github_issues)

Writes GitHub Issues to stdout in a table with borders and colors.

##### Inspired by the book [Programming Elixir](https://pragprog.com/book/elixir16/programming-elixir-1-6) by Dave Thomas.

## Using

To use `GitHub Issues`, first clone it from GitHub:

  - git clone https://github.com/RaymondLoranger/github_issues

Then run these commands to build the escript:

  - cd github_issues
  - mix deps.get
  - mix escript.build

Now you can run the application like so on Windows:

  - escript gi --help
  - escript gi elixir-lang elixir 9 -blt dark

On macOS, you would run the application as follows:

  - ./gi --help
  - ./gi elixir-lang elixir 9 --last --table-style=dark

## Examples
## ![medium](images/medium.png)
## ![medium_alt](images/medium_alt.png)
## ![medium_mult](images/medium_mult.png)
## ![green_alt](images/green_alt.png)
## ![green_mult](images/green_mult.png)
