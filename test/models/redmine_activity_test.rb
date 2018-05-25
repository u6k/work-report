require 'test_helper'

class RedmineActivityTest < ActiveSupport::TestCase

  test "valid model" do
    activity = RedmineActivity.new(entry_title: "updated - Redmine", entry_link: "http://example.redmine.com/issue/1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert activity.valid?
  end

  test "invalid model: title empty" do
    activity = RedmineActivity.new(entry_link: "http://example.redmine.com/issue/1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?

    activity = RedmineActivity.new(entry_title: " ", entry_link: "http://example.redmine.com/issue/1", entry_id: "aaa", entry_updated: DateTime.strptime("2018-05-25T01:23:45Z"))
    assert_not activity.valid?
  end

  test "invalid model: link empty" do
    flunk
  end

  test "invalid model: link format not url" do
    flunk
  end

  test "invalid model: id empty" do
    flunk
  end

  test "invalid model: id not unique" do
    flunk
  end

  test "invalid model: updated empty" do
    flunk
  end

end
