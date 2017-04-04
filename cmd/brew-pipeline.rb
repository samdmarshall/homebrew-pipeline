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

def install(name, version)
  ohai "Setup: Installing #{name}..."
  `gem install #{name} -v '#{version}'`
end

# declare dependencies
found_octokit = Gem::Specification.find_all_by_name('octokit', '4.6.2')

# install them if necessary
install('octokit', '4.6.2') unless !found_octokit.empty?

# now import the things we need
require 'digest'
require 'octokit'

module PipelineCli
  class << self
    # gets the github api token for interacting with repos out of the environment
    # @return [string]
    def apiKey
      return ENV['HOMEBREW_PIPELINE_API_TOKEN']
    end

    # gets the github repo name out of the environment
    # @return [string]
    def repoName
      return ENV['HOMEBREW_PIPELINE_FORMULA_REPO']
    end

    # forks the existing formula tap and opens a new PR with a new formula in it
    # @return [void]
    def createNewFormula(name)
      odie('No formula name provided!') unless name

    end

    # forks the existing formula tap and opens a new PR with a modified version of the existing formula in it
    # @return [void] 
    def updateExistingFormula(name)
      odie('No formula name provided!') unless name
    end

    # validate that we are running from within homebrew's environment
    # @return [void]
    def homebrew!()
      abort("Runtime error: Homebrew is required. Please start via `#{bin} ...`") unless defined?(HOMEBREW_LIBRARY_PATH)
      %w[fileutils pathname tempfile formula utils].each { |req| require(req) }
      extend(FileUtils)
    end

    # primary driver of the command
    # @return [void]
    def run()
      homebrew!

      # parse the argsuments
      command = ARGV.first
      formula_name = ARGV[1]
      case command
      when 'new'
        createNewFormula(formula_name)
      when 'update'
        updateExistingFormula(formula_name)
      else
        onoe "Unknown command `#{command}`!" unless command.nil?
        abort `brew pipeline --help`
      end
    end
  end
end

if PipelineCli.apiKey() == nil || PipelineCli.repoName() == nil
  onoe 'The environment variable `HOMEBREW_PIPELINE_API_TOKEN` is missing from the environment. Please populate this with an access token with repo access!' unless PipelineCli.apiKey()
  onoe 'The environment variable `HOMEBREW_PIPELINE_FORMULA_REPO` is missing from the environment. Please populate this with the `username/reponame` of the repo that stores your homebrew formulae. (e.g.: `samdmarshall/homebrew-formulae`)' unless PipelineCli.repoName()
  abort
end

PipelineCli.run()
