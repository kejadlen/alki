require_relative "test_helper"

require "rack/test"
require "vcr"

ENV["SECRET"] = "aBadSecret"
require "alki/app"

VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :faraday
end

class TestApp < Alki::Test
  include Rack::Test::Methods

  def app
    App
  end

  def setup
    @user_id = DB[:users].insert(trello_id: "some trello id",
                                 access_token: ENV["TEST_ACCESS_TOKEN"],
                                 access_token_secret: ENV["TEST_ACCESS_TOKEN_SECRET"])
  end

  def test_boards
    VCR.use_cassette("test_boards") do
      get "boards", {}, "rack.session" => {user_id: @user_id}
    end

    assert last_response.ok?
    assert_includes last_response.body, "Hiring"
    assert_includes last_response.body, "Welcome Board"
  end

  # def test_add_webhook
  #   board_id = "56903b47301bbf79e2a0b62d"
  #
  #   VCR.use_cassette("test_add_webhook") do
  #     post "webhook", { "board_id" => board_id }, "rack.session" => { user_id: @user_id }
  #   end
  #
  #   assert last_response.ok?
  # end
  #
  # def test_delete_webhook
  #   webhook_id = "some_webhook_id"
  #
  #   VCR.use_cassette("test_delete_webhook") do
  #     delete "webhook/#{webhook_id}", {}, "rack.session" => { user_id: @user_id }
  #   end
  #
  #   assert last_response.ok?
  # end

  def test_board
    VCR.use_cassette("test_board") do
      get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
    end

    assert last_response.ok?

    assert_includes last_response.body, "Hiring"

    ["Kurtis Seebaldt", "Alpha Chen", "Steve Gravrock", "Augustus Lidaka"].each do |name|
      assert_includes last_response.body, name
    end
  end

  def test_cycle_times
    Time.stub :now, Time.parse("2016-01-15") do
      VCR.use_cassette("test_board") do
        get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
      end
    end

    assert last_response.ok?
    assert_match /<th scope="row">Steve Gravrock<\/th>\s*<td>&lt; 1 day<\/td>\s*<td>2 days<\/td>\s*<td>&lt; 1 day<\/td>/, last_response.body
  end

  def test_last_actions
    Time.stub :now, Time.parse("2016-01-15") do
      VCR.use_cassette("test_board") do
        get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
      end
    end

    assert_match /<th scope="row">Kurtis Seebaldt<\/th>\s*<td>3 days<\/td>/, last_response.body
  end

  def test_aggregate_stats
    Time.stub :now, Time.parse("2017-01-15") do
      VCR.use_cassette("test_board") do
        get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
      end
    end

    assert_match /<th scope="row">Average<\/th>\s*<td>&lt; 1 day<\/td>/, last_response.body
  end

  def test_api
    Time.stub :now, Time.parse("2017-01-15") do
      VCR.use_cassette("test_board") do
        get "api/boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
      end
    end

    response = JSON.parse(last_response.body)

    assert_equal "56903b47301bbf79e2a0b62d", response["board_id"]

    list_datum = { "id" => "56903b5cf8dde35f827c63ae", "name" => "Waiting for RPI", "average_duration" => 177.29424999999998 }
    assert_includes response["lists"], list_datum
  end

  def test_board_options
    VCR.use_cassette("test_board") do
      get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
    end

    assert_includes last_response.body, "<h2>Options</h2>"
    assert_match /<input type="checkbox" id="56903b61281e96dd0ae060f2" name="56903b61281e96dd0ae060f2" value="true" \/>\s*<label for="56903b61281e96dd0ae060f2">Waiting for Interview<\/label>/, last_response.body
  end

  def test_update_board_options
    assert_equal 0, DB[:hidden_lists].count

    post "boards/56903b47301bbf79e2a0b62d/options",
         {"569998320bd4f518c6aa2e30" => "true", "5699983462bd7b50af093886" => "true"},
         "rack.session" => {user_id: @user_id}

    assert last_response.redirect?
    follow_redirect!
    assert_equal "http://example.org/boards/56903b47301bbf79e2a0b62d", last_request.url

    assert_equal 2, DB[:hidden_lists].count

    VCR.use_cassette("test_update_board_options") do
      get "boards/56903b47301bbf79e2a0b62d", {}, "rack.session" => {user_id: @user_id}
    end

    refute_includes last_response.body, "<th>More</th>"
    refute_includes last_response.body, "<th>Lists</th>"
    assert_includes last_response.body, "<input type=\"checkbox\" id=\"569998320bd4f518c6aa2e30\" name=\"569998320bd4f518c6aa2e30\" value=\"true\" checked=\"checked\" />"
    assert_includes last_response.body, "<input type=\"checkbox\" id=\"5699983462bd7b50af093886\" name=\"5699983462bd7b50af093886\" value=\"true\" checked=\"checked\" />"
  end
end
