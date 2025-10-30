require "test_helper"

class DocumentGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get document_groups_show_url
    assert_response :success
  end
end
