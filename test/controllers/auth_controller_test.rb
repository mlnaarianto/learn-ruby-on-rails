require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get auth_login_url
    assert_response :success
  end

  test "should get omniauth" do
    get auth_omniauth_url
    assert_response :success
  end
end
