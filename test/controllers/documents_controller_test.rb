require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = users(:client)
    @manager = users(:manager)
    @document = documents(:one)
  end

  test "client sees only their documents" do
    log_in_as(@client)
    get documents_url
    assert_response :success
    assert_select "div#documents", /#{@document.title}/
  end

  setup do
    @admin = users(:admin)
  end

  test "admin sees all documents" do
    log_in_as(@admin)
    get documents_url
    assert_response :success
  end

  private

  def log_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "admin" }
  end
end
