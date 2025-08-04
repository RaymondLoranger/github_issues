import Config

scheme = "https"
host = "api.github.com"
path = "/repos/<%=user%>/<%=project%>/issues"

config :github_issues, url_template: "#{scheme}://#{host}#{path}"
