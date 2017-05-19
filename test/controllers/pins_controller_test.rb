require 'test_helper'

class PinsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pins_index_url
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

end
