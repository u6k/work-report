class GithubActivity < ApplicationRecord

  validates :event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :event_created, presence: true
  validates :event_payload_size, presence: true

end
