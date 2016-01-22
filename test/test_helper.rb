require "minitest/autorun"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "alki/db"

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
