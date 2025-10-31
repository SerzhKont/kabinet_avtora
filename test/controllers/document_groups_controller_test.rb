require "test_helper"

class DocumentGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get show with valid token" do
    group = document_groups(:valid_group)
    get document_group_url(group.token)
    assert_response :success
  end

  test "should not get show with invalid token" do
    get document_group_url("invalid_token")
    assert_response :not_found
  end

  test "should not get show with expired token" do
    group = document_groups(:expired_group)
    get document_group_url(group.token)
    assert_response :not_found
  end
end
