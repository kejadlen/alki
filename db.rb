require "sequel"

Sequel::Model.plugin :timestamps, update_on_create: true

module Alki
  DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
  DB.extension :pg_json

   module Models
     class User < Sequel::Model; end
     class Action < Sequel::Model; end
   end
end
