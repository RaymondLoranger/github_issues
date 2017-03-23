# GitHub Issues

Prints GitHub Issues to STDOUT in a table with borders and colors.

## Using

To use `Github Issues` clone it from GitHub:

git clone https://github.com/RaymondLoranger/github_issues

Then run these commands to build the escript:

cd github_issues
mix deps.get
mix escript.build

Now you can run the application:

escript gi --help
escript gi elixir-lang elixir 9 --last --table-style=dark

## Example

escript gi elixir-lang elixir 9 --last --table-style=dark
## ![github_issues_example](images/github_issues_example.png)
