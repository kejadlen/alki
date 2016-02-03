require "minitest/autorun"

require "dotenv"
Dotenv.overload(File.expand_path("../../.test.envrc", __FILE__))
ENV["DATABASE_URL"] = "postgres://localhost/alki_test"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "alki/db"

Sequel.extension :migration
Sequel::Migrator.run(Alki::DB, File.expand_path("../../db/migrations", __FILE__))

module Alki
  class Test < Minitest::Test
    def run(*args, &block)
      DB.transaction(rollback: :always, auto_savepoint: true) do
        super
      end
    end
  end
end

include Alki
