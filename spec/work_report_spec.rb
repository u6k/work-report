RSpec.describe WorkReport do
  it "has a version number" do
    expect(WorkReport::VERSION).not_to be nil
  end

  describe WorkReport::GithubActivity do
    before do
      @github_activity = WorkReport::GithubActivity.new("u6k", ENV["GITHUB_TOKEN"])
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
  end
end

