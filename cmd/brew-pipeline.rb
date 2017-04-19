#: * `pipeline`
#:    Easily create or update formulae from brew itself
#:
#: `brew pipeline new [formula name] ...`
#:  Create a new formula with a given name
#:
#: `brew pipeline update [formula name] ...` 
#:
#: Supported Flags:
#:
#: * `--tag="tag string"`
#:    used to specify the name of the tagged version to use. if this is not supplied, then brew will expect you to install using the `--HEAD` flag.
#:
#: * `--repo="repo-address"`
#:    Used to specify the url address of the repository the formula should install from.

has_octokit_installed = `/usr/bin/gem list octokit`.include?("octokit")
has_required_gems = has_octokit_installed

if !has_required_gems
  odie "The command `pipeline` requires the gem 'octokit' be installed; please ensure it is accessible by the system ruby: /usr/bin/gem install octokit"
end

require_relative 'pipeline-cli.rb'

if PipelineCli.apiKey() == nil || PipelineCli.repoSlug() == nil
  onoe 'The environment variable `HOMEBREW_PIPELINE_API_TOKEN` is missing from the environment. Please populate this with an access token with repo access!' unless PipelineCli.apiKey()
  onoe 'The environment variable `HOMEBREW_PIPELINE_FORMULA_REPO` is missing from the environment. Please populate this with the `username/reponame` of the repo that stores your homebrew formulae. (e.g.: `samdmarshall/homebrew-formulae`)' unless PipelineCli.repoName()
  abort
end

PipelineCli.run()
