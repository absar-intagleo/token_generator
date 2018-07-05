require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get authenticate" do
    get home_authenticate_url
    assert_response :success
  end

end
