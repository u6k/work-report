require 'test_helper'

class RedmineActivityTest < ActiveSupport::TestCase

  def setup
    bucket = NetModule.get_s3_bucket
    bucket.objects.batch_delete!
  end

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

  test "download redmine activity atom" do
    # precondition
    s3_bucket = NetModule.get_s3_bucket
    assert_not s3_bucket.object("redmine_activity.atom").exists?
    assert_equal 0, RedmineActivity.all.length

    # execute
    s3_object_keys = RedmineActivity.download_redmine_activity_atom("https://redmine.u6k.me/activity.atom?key=6c9b0fe50d9bdcc2e4da1215b7187aededf36652&user_id=5")

    activities = RedmineActivity.parse_redmine_activity_atom(s3_object_keys[:original])

    # postcondition
    assert_equal "redmine_activity.atom", s3_object_keys[:original]
    assert_match /^redmine_activity\.atom\.bak_\d{14}$/, s3_object_keys[:backup]

    assert s3_bucket.object(s3_object_keys[:original]).exists?
    assert s3_bucket.object(s3_object_keys[:backup]).exists?

    assert activities.length > 0
    assert_equal 0, RedmineActivity.all.length
  end

  test "import redmine activity atom" do
    # setup
    s3_bucket = NetModule.get_s3_bucket
    s3_bucket.object("redmine_activity.latest.atom").put(body: File.read("test/fixtures/files/redmine_activity.atom"))

    # precondition
    assert_equal 0, RedmineActivity.all.length

    # execute
    activities = RedmineActivity.parse_redmine_activity_atom("redmine_activity.latest.atom")
    activity_ids = RedmineActivity.import(activities)

    # postcondition
    assert_equal 513, activities.length
    assert_equal activities.length, activity_ids.length

    activities.each do |activity|
      activity_actual = RedmineActivity.find_by(entry_id: activity.entry_id)
      assert_same_redmine_activity activity, activity_actual
    end
  end

  test "import duplicate redmine activity" do
    # precondition
    assert_equal 0, RedmineActivity.all.length

    # execute
    activities = [
      RedmineActivity.new(entry_title: "aaa", entry_link: "http://example.redmine.com/issue/aaa", entry_id: "aaa", entry_updated: DateTime.parse("2018-01-01T00:00:00Z")),
      RedmineActivity.new(entry_title: "bbb", entry_link: "http://example.redmine.com/issue/bbb", entry_id: "bbb", entry_updated: DateTime.parse("2018-01-01T00:00:00Z")),
      RedmineActivity.new(entry_title: "ccc", entry_link: "http://example.redmine.com/issue/ccc", entry_id: "ccc", entry_updated: DateTime.parse("2018-01-01T00:00:00Z"))
    ]
    activity_ids  = RedmineActivity.import(activities)

    assert_equal 3, activity_ids.length
    assert_equal 3, RedmineActivity.all.length

    activities = [
      RedmineActivity.new(entry_title: "aaa", entry_link: "http://example.redmine.com/issue/aaa", entry_id: "aaa", entry_updated: DateTime.parse("2018-01-01T00:00:00Z")),
      RedmineActivity.new(entry_title: "bbb", entry_link: "http://example.redmine.com/issue/bbb", entry_id: "bbb", entry_updated: DateTime.parse("2018-01-01T00:00:00Z")),
      RedmineActivity.new(entry_title: "ccc", entry_link: "http://example.redmine.com/issue/ccc", entry_id: "ccc", entry_updated: DateTime.parse("2018-01-01T00:00:00Z")),
      RedmineActivity.new(entry_title: "ddd", entry_link: "http://example.redmine.com/issue/ddd", entry_id: "ddd", entry_updated: DateTime.parse("2018-01-01T00:00:00Z"))
    ]
    activity_ids = RedmineActivity.import(activities)

    # postcondition
    assert_equal 1, activity_ids.length
    assert_equal 4, RedmineActivity.all.length

    activities.each do |activity|
      activity_actual = RedmineActivity.find_by(entry_id: activity.entry_id)

      assert_same_redmine_activity activity, activity_actual
    end
  end

  test "count redmine activities per day" do
    # setup
    activities = [
      RedmineActivity.new(entry_title: "aaa", entry_link: "http://example.redmine.com/issue/aaa", entry_id: "aaa", entry_updated: DateTime.parse("2018-01-01T01:01:01Z")),
      RedmineActivity.new(entry_title: "bbb", entry_link: "http://example.redmine.com/issue/bbb", entry_id: "bbb", entry_updated: DateTime.parse("2018-01-03T03:31:32Z")),
      RedmineActivity.new(entry_title: "ccc", entry_link: "http://example.redmine.com/issue/ccc", entry_id: "ccc", entry_updated: DateTime.parse("2018-01-03T015:13:23Z")),
      RedmineActivity.new(entry_title: "ddd", entry_link: "http://example.redmine.com/issue/ddd", entry_id: "ddd", entry_updated: DateTime.parse("2018-01-02T02:02:02Z")),
      RedmineActivity.new(entry_title: "eee", entry_link: "http://example.redmine.com/issue/eee", entry_id: "eee", entry_updated: DateTime.parse("2018-01-02T14:20:20Z")),
      RedmineActivity.new(entry_title: "fff", entry_link: "http://example.redmine.com/issue/fff", entry_id: "fff", entry_updated: DateTime.parse("2018-01-02T06:06:06Z"))
    ]
    RedmineActivity.import(activities)

    # precondition
    assert_equal 6, RedmineActivity.all.length

    # execute
    count_activities = RedmineActivity.count_redmine_activities_per_day

    # postcondition
    assert_equal 3, count_activities.length

    assert_equal 1, count_activities["2018-01-01"]
    assert_equal 3, count_activities["2018-01-02"]
    assert_equal 2, count_activities["2018-01-03"]
  end

  def assert_same_redmine_activity(expected, actual)
    assert_equal expected.entry_title, actual.entry_title
    assert_equal expected.entry_link, actual.entry_link
    assert_equal expected.entry_id, actual.entry_id
    assert_equal expected.entry_updated, actual.entry_updated
  end

end
