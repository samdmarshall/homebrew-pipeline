require 'digest'
require 'octokit'

module PipelineCli
  class << self

    @octo_client = nil
     
    # gets the github api token for interacting with repos out of the environment
    # @return [string]
    def apiKey()
      return ENV['HOMEBREW_PIPELINE_API_TOKEN']
    end

    # gets the github repo name out of the environment
    # @return [string]
    def repoSlug()
      return ENV['HOMEBREW_PIPELINE_FORMULA_REPO'].split('/')
    end

    def getUserName()
      return repoSlug.first
    end

    def getRepo()
      return repoSlug.last
    end

    # gets the hostname of the github instance that homebrew-pipeline should assume that the formula repo lives
    # @return [string]
    def githubAPIEndpoint()
      domain = 'api.github.com' unless ENV['HOMEBREW_PIPELINE_GITHUB_DOMAIN']
      return "https://#{domain}/"
    end

    def githubWebEndpoint()
      domain = 'github.com' unless ENV['HOMEBREW_PIPELINE_GITHUB_WEB_DOMAIN']
      return "https://#{domain}/"
    end

    # creates the client to interface with the github API
    def setupClient!()
      @octo_client = Octokit::Client.new(
        :access_token => apiKey(),
        :api_endpoint => githubAPIEndpoint(),
        :web_endpoint => githubWebEndpoint()
      )
      @octo_client.auto_paginate = true
    end

    # forks the existing formula tap and opens a new PR with a new formula in it
    # @return [void]
    def createNewFormula(name)
      odie('No formula name provided!') unless name
      
      setupClient!

      #odie("Formula with name #{name} doesn't exist!") unless (name in @octo_client.all_repositories)
    end

    # forks the existing formula tap and opens a new PR with a modified version of the existing formula in it
    # @return [void] 
    def updateExistingFormula(name)
      odie('No formula name provided!') unless name

      setupClient!

      ohai("Fetching repo data")
      user_repos = @octo_client.repositories(getUserName())
      user_repo_names = user_repos.map(&:name)
      if !user_repo_names.include?(name)
        odie("Formula with name #{name} doesn't exist!")
      end

      ohai("Cloning #{githubWebEndpoint}#{repoSlug.join('/')}")

      remaining_args = ARGV[2..ARGV.length]

      # Formula.initialize(name, 
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
