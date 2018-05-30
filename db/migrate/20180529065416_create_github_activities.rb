class CreateGithubActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :github_activities do |t|
      t.string :event_id
      t.string :event_type
      t.datetime :event_created
      t.integer :event_payload_size

      t.timestamps
    end
  end
end
