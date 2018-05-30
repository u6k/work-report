require 'test_helper'

class GithubActivityTest < ActiveSupport::TestCase

  def setup
    bucket = NetModule.get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "valid model" do
    activity = GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert activity.valid?
  end

  test "invalid model: id empty" do
    activity = GithubActivity.new(event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert_not activity.valid?

    activity = GithubActivity.new(event_id: " ", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert_not activity.valid?
  end

  test "invalid model: id not unique" do
    GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1).save!
    GithubActivity.new(event_id: "2222222222", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:02:02Z"), event_payload_size: 1).save!
    GithubActivity.new(event_id: "3333333333", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:23:03Z"), event_payload_size: 3).save!

    activity = GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert_not activity.valid?
  end

  test "invalid model: type empty" do
    activity = GithubActivity.new(event_id: "1111111111", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert_not activity.valid?

    activity = GithubActivity.new(event_id: "1111111111", event_type: " ", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1)
    assert_not activity.valid?
  end

  test "invalid model: created empty" do
    activity = GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_payload_size: 1)
    assert_not activity.valid?
  end

  test "download github activity json" do
    # precondition
    s3_bucket = NetModule.get_s3_bucket
    assert_not s3_bucket.object("github_activity.json").exists?
    assert_equal 0, GithubActivity.all.length

    # execute
    s3_object_keys = GithubActivity.download_json("u6k", false)

    activities = GithubActivity.parse_json(s3_object_keys[:original])

    # postcondition
    assert_equal "github_activity.json", s3_object_keys[:original]
    assert_match /^github_activity\.json\.bak_\d{14}$/, s3_object_keys[:backup]

    assert s3_bucket.object(s3_object_keys[:original]).exists?
    assert s3_bucket.object(s3_object_keys[:backup]).exists?

    assert activities.length > 0
    assert_equal 0, GithubActivity.all.length
  end

  test "download all github activity json" do
    # precondition
    s3_bucket = NetModule.get_s3_bucket
    (1..10).each do |page_number|
      assert_not s3_bucket.object("github_activity.page#{page_number}.json").exists?
    end
    assert_equal 0, GithubActivity.all.length

    # execute
    s3_object_keys_array = GithubActivity.download_json("u6k", true)

    activities = []
    s3_object_keys_array.each do |s3_object_keys|
      activities += GithubActivity.parse_json(s3_object_keys[:original])
    end

    # postcondition
    s3_object_keys_array.each do |s3_object_keys, index|
      assert_match /^github_activity\.page\d{1,2}\.json$/, s3_object_keys[:original]
      assert_match /^github_activity\.page\d{1,2}\.json\.bak_\d{14}$/, s3_object_keys[:backup]

      assert s3_bucket.object(s3_object_keys[:original]).exists?
      assert s3_bucket.object(s3_object_keys[:backup]).exists?
    end

    assert_equal 300, activities.length
    assert_equal 0, GithubActivity.all.length

    # import
    GithubActivity.import(activities)

    assert_equal 300, GithubActivity.all.length
  end

  test "impoet github activity json" do
    # setup
    s3_bucket = NetModule.get_s3_bucket
    s3_bucket.object("github_activity.json").put(body: File.read("test/fixtures/files/github_activity.json"))

    # precondition
    assert_equal 0, GithubActivity.all.length

    # execute
    activities = GithubActivity.parse_json("github_activity.json")
    activity_ids = GithubActivity.import(activities)

    # postcondition
    assert_equal 30, activities.length
    assert_equal activities.length, activity_ids.length

    activities.each do |activity|
      activity_actual = GithubActivity.find_by(event_id: activity.event_id)
      assert_same_github_activity activity, activity_actual
    end
  end

  test "import duplicate redmine activity" do
    # precondition
    assert_equal 0, GithubActivity.all.length

    # execute
    activities = [
      GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "2222222222", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:02:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "3333333333", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:23:03Z"), event_payload_size: 3)
    ]
    activity_ids = GithubActivity.import(activities)

    assert_equal 3, activity_ids.length
    assert_equal 3, GithubActivity.all.length

    activities = [
      GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "2222222222", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:02:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "3333333333", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:23:03Z"), event_payload_size: 3),
      GithubActivity.new(event_id: "4444444444", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-30T21:34:45Z"), event_payload_size: 1)
    ]
    activity_ids = GithubActivity.import(activities)

    # postcondition
    assert_equal 1, activity_ids.length
    assert_equal 4, GithubActivity.all.length

    activities.each do |activity|
      activity_actual = GithubActivity.find_by(event_id: activity.event_id)
      assert_same_github_activity activity, activity_actual
    end
  end

  test "count github activities per day" do
    # setup
    activities = [
      GithubActivity.new(event_id: "1111111111", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:01:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "2222222222", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:02:02Z"), event_payload_size: 1),
      GithubActivity.new(event_id: "3333333333", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-29T16:23:03Z"), event_payload_size: 3),
      GithubActivity.new(event_id: "4444444444", event_type: "TestEvent", event_created: DateTime.strptime("2018-05-30T21:34:45Z"), event_payload_size: 1)
    ]
    GithubActivity.import(activities)

    # precondition
    assert_equal 4, GithubActivity.all.length

    # execute
    count_activities = GithubActivity.count_per_day

    # postcondition
    assert_equal 2, count_activities.length

    assert_equal 5, count_activities["2018-05-29"]
    assert_equal 1, count_activities["2018-05-30"]
  end

  def assert_same_github_activity(expected, actual)
    assert_equal expected.event_id, actual.event_id
    assert_equal expected.event_type, actual.event_type
    assert_equal expected.event_created, actual.event_created
    assert_equal expected.event_payload_size, actual.event_payload_size
  end

end
