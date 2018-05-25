class RedmineActivity < ApplicationRecord

  validates :entry_title, presence: true
  validates :entry_link, presence: true, format: /\A#{URI::regexp(%w(http https))}\z/
  validates :entry_id, presence: true, uniqueness: true
  validates :entry_updated, presence: true

  def self.download_redmine_activity_atom(url)
    raise "TODO" # TODO
  end

  def self.parse_redmine_activity_atom(s3_object_key)
    raise "TODO" # TODO
  end

  def self.import(redmine_activities)
    raise "TODO" # TODO
  end

end
