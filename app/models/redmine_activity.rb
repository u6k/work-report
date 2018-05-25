class RedmineActivity < ApplicationRecord
  validates :entry_title, presence: true
  validates :entry_link, presence: true, format: /\A#{URI::regexp(%w(http https))}\z/
  validates :entry_id, presence: true, uniqueness: true
  validates :entry_updated, presence: true
end
