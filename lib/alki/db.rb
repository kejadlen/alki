require "sequel"

Sequel::Model.plugin :timestamps, update_on_create: true

module Alki
  DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
  DB.extension :pg_json

   module Models
     class User < Sequel::Model
       def board(board_id)
         trello.boards(board_id)
       end

       def boards
         trello.members_me_boards
       end

       def cards(board_id)
         trello.boards_cards(board_id)
       end

       def lists(board_id)
         trello.boards_lists(board_id)
       end

       def delete_webhook(webhook_id)
         trello.delete_webhook(webhook_id)
       end

       def add_webhook(board_id:, callback_url:)
         trello.add_webhook(board_id: board_id, callback_url: callback_url)
       end

       def webhooks
         trello.token_webhooks
       end

       private

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
