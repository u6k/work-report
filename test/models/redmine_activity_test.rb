require 'test_helper'

class RedmineActivityTest < ActiveSupport::TestCase

  test "valid model" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http://example.redmine.com/issue/1#change=12345?page=1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert activity.valid?
  end

  test "invalid model: title empty" do
    activity = RedmineActivity.new(entry_link: "http://example.redmine.com/issue/1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?

    activity = RedmineActivity.new(entry_title: " ", entry_link: "http://example.redmine.com/issue/1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?
  end

  test "invalid model: link empty" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?

    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: " ", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?
  end

  test "invalid model: link format not url" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?
  end

  test "invalid model: id empty" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http://example.redmine.com/issue/1#change=12345?page=1", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?

    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http://example.redmine.com/issue/1#change=12345?page=1", entry_id: " ", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?
  end

  test "invalid model: id not unique" do
    RedmineActivity.new(entry_title: "updated 1 - Redmine", entry_link: "http://example.redmine.com/issue/1", entry_id: "1", entry_updated: DateTime.strptime("2018-05-25T00:00:00Z")).save!
    RedmineActivity.new(entry_title: "updated 2 - Redmine", entry_link: "http://example.redmine.com/issue/2", entry_id: "2", entry_updated: DateTime.strptime("2018-05-25T00:00:00Z")).save!
    RedmineActivity.new(entry_title: "updated 3 - Redmine", entry_link: "http://example.redmine.com/issue/3", entry_id: "3", entry_updated: DateTime.strptime("2018-05-25T00:00:00Z")).save!

    activity = RedmineActivity.new(entry_title: "updated 2 - Redmine", entry_link: "http://example.redmine.com/issue/2", entry_id: "2", entry_updated: DateTime.strptime("2018-05-25T00:00:00Z"))
    assert_not activity.valid?
  end

  test "invalid model: updated empty" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http://example.redmine.com/issue/1#change=12345?page=1", entry_id: "aaa")
    assert_not activity.valid?
  end

end
