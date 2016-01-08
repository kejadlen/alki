require "minitest/autorun"
require "rack/test"

ENV["DATABASE_URL"] = "postgres://localhost/alki_test"
ENV["SECRET"] = "aBadSecret"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "alki/app"

Sequel.extension :migration
Sequel::Migrator.run(Alki::DB, "db/migrations")

module Alki
  class TestAlki < Minitest::Test
    include Rack::Test::Methods

    def run(*args, &block)
      DB.transaction(rollback: :always, auto_savepoint: true) do
        super
      end
    end

    def app
      App.freeze.app
    end

    def test_alki
      get("/")

      assert_nil last_response
    end
  end
end