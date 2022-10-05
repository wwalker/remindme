require "test_helper"

class RemindersControllerTest < ActionDispatch::IntegrationTest
  test "should get next_time" do
    get reminders_next_time_url
    assert_response :success
  end

  test "should get waiting" do
    get reminders_waiting_url
    assert_response :success
  end
end
