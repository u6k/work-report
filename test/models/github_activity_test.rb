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

    # postcondition
    assert_equal "github_activitjson", s3_object_keys[:original]
    assert_match /^github_activity\.json\.bak_\d{14}$/, s3_object_keys[:backup]

    assert s3_bucket.object(s3_object_keys[:original]).exists?
    assert s3_bucket.object(s3_object_keys[:backup]).exists?

    assert activities.length > 0
    assert_equal 0, GithubActivity.all.length
  end

end
