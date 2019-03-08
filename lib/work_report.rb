require "json"
require "csv"
require "open-uri"
require "thor"
require "nokogiri"

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

  class RedmineActivity
    def initialize(redmine_url, redmine_api_key, redmine_user_id)
      @redmine_url = redmine_url
      @redmine_api_key = redmine_api_key
      @redmine_user_id = redmine_user_id
    end

    def activities_to_hash
      url = "#{@redmine_url}/activity.atom?key=#{@redmine_api_key}&user_id=#{@redmine_user_id}"

      atom = open(url) do |f|
        f.read
      end

      doc = Nokogiri::XML.parse(atom, nil, "UTF-8")
      doc.remove_namespaces!

      activities = doc.xpath("/feed/entry").map do |entry|
        title = entry.at_xpath("title").to_str
        project = title.split(" - ", 2)[0]
        title = title.split(" - ", 2)[1]

        url = entry.at_xpath("link/@href").to_str

        timestamp = entry.at_xpath("updated").to_str
        #timestamp = Time.parse(timestamp).strftime("%Y-%m-%d %H:%M:%S")
        timestamp = Time.parse(timestamp)
        #ENV["TZ"] = "Asia/Tokyo"
        #timestamp = timestamp.localtime
        #ENV["TZ"] = "UTC"
        #timestamp = timestamp.strftime("%Y-%m-%d %H:%M:%S")

        {
          "project" => project,
          "title" => title,
          "url" => url,
          "timestamp" => timestamp
        }
      end
    end

    def activities_to_csv
      activities = activities_to_hash

      csv = CSV.generate do |line|
        activities.each do |activity|
          line << [activity["project"], activity["title"], activity["url"], activity["timestamp"].strftime("%F %T")]
        end
      end
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

    desc "redmine_activities", "Output redmine activities to csv"
    method_option :redmine_url
    method_option :redmine_api_key
    method_option :redmine_user_id
    def redmine_activities
      redmine_activity = RedmineActivity.new(options.redmine_url, options.redmine_api_key, options.redmine_user_id)
      puts redmine_activity.activities_to_csv
    end
  end
end

