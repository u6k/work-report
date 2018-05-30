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
    puts doc.inspect # TODO
  end

end
