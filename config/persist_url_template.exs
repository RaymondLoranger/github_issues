import Config

config :github_issues,
  url_template: "https://api.github.com/repos/<%=user%>/<%=project%>/issues"
