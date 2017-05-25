
# GitHub Issues

Prints GitHub Issues to STDOUT in a table with borders and colors.

## Using

To use `GitHub Issues`, first clone it from GitHub:

  - git clone https://github.com/RaymondLoranger/github_issues

Then run these commands (in **Powershell** on Windows) to build the escript:

  - cd github_issues
  - chcp 65001 (on Windows)
  - mix deps.get
  - mix escript.build

Now you can run the application like so on Windows:

  - escript gi --help (now in colors)
  - escript gi elixir-lang elixir 9 --last --table-style=dark

On macOS, you would run the application as follows:

  - ./gi --help
  - ./gi elixir-lang elixir 9 --last --table-style=dark

N.B. The escript is named `gi` for **g**ithub_**i**ssues. The ideal
background color is **navy blue**.

## Examples
## ![github_issues_examples](images/github_issues_examples.png)
