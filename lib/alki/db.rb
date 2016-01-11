require "sequel"

Sequel::Model.plugin :timestamps, update_on_create: true

module Alki
  DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
  DB.extension :pg_json

   module Models
     class User < Sequel::Model
       def boards
         self.trello.members_me_boards
       end

       def trello
         return @trello if defined?(@trello)
         @trello = Trello::Authed.new(api_key: ENV["TRELLO_KEY"],
                                      api_secret: ENV["TRELLO_SECRET"],
                                      access_token: self.access_token,
                                      access_token_secret: self.access_token_secret)
       end
     end

     class Action < Sequel::Model; end
   end
end
