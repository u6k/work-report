require "json"
require "csv"
require "open-uri"
require "thor"

require "work_report/version"

module WorkReport
  class GithubActivity
    def initialize(user, github_token)
      @user = user
      @github_token = github_token
    end

    def commits_to_hash
      # get contributions
      url = "https://github-contributions-api.now.sh/v1/#{@user}"
      
      json = open(url) do |f|
        JSON.load(f.read)
      end
      
      # convert summary
      counts = json["contributions"].map do |contribution|
        {
          "date" => Time.parse(contribution["date"]),
          "count" => contribution["count"]
        }
      end
    end

    def commits_to_csv
      commits = commits_to_hash

      csv = CSV.generate do |line|
        commits.each do |commit|
          line << [commit["date"].strftime("%F"), commit["count"]]
        end
      end
    end

    def releases_to_hash
      # get repos
      repos_url = "https://api.github.com/users/#{@user}/repos"
      
      repos = get_github_data(repos_url)
      
      # get releases
      releases = repos.flat_map do |repo|
        releases_url = "https://api.github.com/repos/#{@user}/#{repo["name"]}/releases"
      
        releases = get_github_data(releases_url)
      end
      
      releases.compact!
      
      # convert release summary
      release_summaries = releases.map do |release|
        {
          "url" => release["html_url"],
          "name" => release["name"],
          "created_at" => Time.parse(release["created_at"])
        }
      end
    end

    def releases_to_csv
      releases = releases_to_hash

      csv = CSV.generate do |line|
        releases.each do |release|
          line << [release["url"], release["name"], release["created_at"].strftime("%F %T")]
        end
      end
    end

    private

    def get_github_data(url)
      data = open(url, "Authorization" => "token #{@github_token}") do |f|
        sleep 1
    
        current_data = JSON.load(f.read)
    
        if not f.meta["link"].nil?
          parent_data = f.meta["link"].match(/<([^<>]+)>; rel=\"next\"/) do |link|
            get_github_data(link[1])
          end
        end
    
        if parent_data.nil?
          current_data
        else
          current_data + parent_data
        end
      end
    
      data
    end
  end

  class CLI < Thor
    desc "github_commits", "Output github commits to csv"
    method_option :github_user
    def github_commits
      github_activity = GithubActivity.new(options.github_user, nil)
      puts github_activity.commits_to_csv
    end

    desc "github_releases", "Output github releases to csv"
    method_option :github_user
    method_option :github_token
    def github_releases
      github_activity = GithubActivity.new(options.github_user, options.github_token)
      puts github_activity.releases_to_csv
    end
  end
end

