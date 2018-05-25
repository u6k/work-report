class CreateRedmineActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_activities do |t|
      t.string :entry_title
      t.string :entry_link
      t.string :entry_id
      t.datetime :entry_updated

      t.timestamps
    end
  end
end
