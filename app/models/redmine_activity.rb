class RedmineActivity < ApplicationRecord

  validates :entry_title, presence: true
  validates :entry_link, presence: true, format: /\A#{URI::regexp(%w(http https))}\z/
  validates :entry_id, presence: true, uniqueness: true
  validates :entry_updated, presence: true

  def self.download_atom(url)
    file_name = "redmine_activity.atom"

    keys = NetModule.download_with_get(url, file_name)
  end

  def self.parse_atom(s3_object_key)
    bucket = NetModule.get_s3_bucket
    atom = bucket.object(s3_object_key).get.body

    doc = Nokogiri::XML.parse(atom, nil, "UTF-8")
    doc.remove_namespaces!

    entries = doc.xpath("/feed/entry")

    activities = entries.map do |entry|
      activity = RedmineActivity.new(
        entry_title: entry.xpath("title").text,
        entry_link: entry.xpath("link").first["href"],
        entry_id: entry.xpath("id").text,
        entry_updated: DateTime.parse(entry.xpath("updated").text)
      )

      raise activity.errors.messages.to_s if activity.invalid?

      activity
    end
  end

  def self.import(redmine_activities)
    activity_ids = []

    redmine_activities.each do |activity|
      if activity.valid?
        activity.save!
        activity_ids << activity.id
      end
    end

    activity_ids
  end

  def self.count_per_day
    count_activities_result = RedmineActivity.find_by_sql("select date_trunc('day', entry_updated) as date, count(1) as count from redmine_activities group by date")

    count_activities = count_activities_result.map do |count|
      [count.date.strftime("%Y-%m-%d"), count.count]
    end.to_h
  end

end
