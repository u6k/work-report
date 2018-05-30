require "json"

class GithubActivity < ApplicationRecord

  validates :event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :event_created, presence: true
  validates :event_payload_size, presence: true

  def self.download_json(github_user_id, all = false)
    url = "https://api.github.com/users/#{github_user_id}/events"
    file_name = "github_activity.json"

    keys = NetModule.download_with_get(url, file_name)
  end

  def self.parse_json(s3_object_key)
    bucket = NetModule.get_s3_bucket
    json = bucket.object(s3_object_key).get.body.read

    doc = JSON.parse(json)

    activities = doc.map do |event|
      activity = GithubActivity.new(
        event_id: event["id"],
        event_type: event["type"],
        event_created: DateTime.parse(event["created_at"]),
        event_payload_size: 1
      )

      if activity.event_type == "PushEvent"
        activity.event_payload_size = event["payload"]["size"]
      end

      raise activity.errors.messages.to_s if activity.invalid?

      activity
    end
  end

  def self.import(github_activities)
    activity_ids = []

    github_activities.each do |activity|
      if activity.valid?
        activity.save!
        activity_ids << activity.id
      end
    end

    activity_ids
  end

  def self.count_per_day
    count_activities_result = GithubActivity.find_by_sql("select date_trunc('day', event_created) as date, sum(event_payload_size) as count from github_activities group by date")

    count_activities = count_activities_result.map do |count|
      [count.date.strftime("%Y-%m-%d"), count.count]
    end.to_h
  end

end
