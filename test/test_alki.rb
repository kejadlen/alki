require "minitest/autorun"
require "rack/test"
require "vcr"

ENV["DATABASE_URL"] = "postgres://localhost/alki_test"
ENV["SECRET"] = "aBadSecret"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "alki/app"

Sequel.extension :migration
Sequel::Migrator.run(Alki::DB, "db/migrations")

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :faraday
end

module Alki
  class TestAlki < Minitest::Test
    include Rack::Test::Methods

    def app
      App
    end

    def run(*args, &block)
      DB.transaction(rollback: :always, auto_savepoint: true) do
        super
      end
    end

    def setup
      @user = Models::User.create(trello_id: "some trello id",
                                  access_token: ENV["TEST_ACCESS_TOKEN"],
                                  access_token_secret: ENV["TEST_ACCESS_TOKEN_SECRET"])
    end

    def test_boards
      VCR.use_cassette("test_boards") do
        get "boards", {}, "rack.session" => { user_id: @user.id }
      end

      assert last_response.ok?
      assert_includes last_response.body, "Welcome Board"
      assert_includes last_response.body, "Hiring"
    end
  end
end