RSpec.describe WorkReport do
  it "has a version number" do
    expect(WorkReport::VERSION).not_to be nil
  end

  describe WorkReport::GithubActivity do
    before do
      @github_activity = WorkReport::GithubActivity.new(ENV["GITHUB_USER"], ENV["GITHUB_TOKEN"])
    end

    describe "#commits_to_hash" do
      it "is hash" do
        commits = @github_activity.commits_to_hash

        expect(commits.size).to be > 0

        commits.each do |commit|
          expect(commit["date"]).to be_is_a Time
          expect(commit["count"]).to be_integer
        end
      end
    end

    describe "#commits_to_csv" do
      it "is csv" do
        csv = @github_activity.commits_to_csv

        csv.each_line do |line|
          expect(line).to match /^\d{4}-\d{2}-\d{2},\d+$/
        end
      end
    end

    describe "#releases_to_hash" do
      it "is hash" do
        releases = @github_activity.releases_to_hash

        expect(releases.size).to be > 0

        releases.each do |release|
          expect(release["url"]).to start_with "https://github.com/u6k/"
          expect(release["name"]).to match /\w+/
          expect(release["created_at"]).to be_is_a Time
        end
      end
    end

    describe "#releases_to_csv" do
      it "is csv" do
        csv = @github_activity.releases_to_csv

        csv.each_line do |line|
          expect(line).to match /^https:\/\/github\.com\/.+?,.+?,\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/
        end
      end
    end
  end

  describe WorkReport::RedmineActivity do
    before do
      @redmine_activity = WorkReport::RedmineActivity.new(ENV["REDMINE_URL"], ENV["REDMINE_API_KEY"], ENV["REDMINE_USER_ID"])
    end

    describe "#activities_to_hash" do
      it "is hash" do
        activities = @redmine_activity.activities_to_hash

        expect(activities.size).to be > 0

        activities.each do |activity|
          expect(activity["project"]).to match /^.+$/
          expect(activity["title"]).to match /^.+$/
          expect(activity["url"]).to match /^http.*$/
          expect(activity["timestamp"]).to be_is_a Time
        end
      end
    end

    describe "#activities_to_csv" do
      it "is csv" do
        csv = @redmine_activity.activities_to_csv

        csv.each_line do |line|
          expect(line).to match /^.+?,.+?,http.+?,\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/
        end
      end
    end
  end
end

