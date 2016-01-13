require_relative "trello"

module Alki
  module Models
    class TrelloModel
      def self.trello_attr(*attrs)
        attrs.each do |attr|
          define_method("trello_#{attr}") do
            self.raw[attr.to_s]
          end
        end
      end

      attr_reader :raw

      def initialize(raw:, trello:)
        @raw, @trello = raw, trello
      end

      private

      def trello
        @trello
      end
    end

    class Board < TrelloModel
      trello_attr :id, :name

      def actions
        trello.boards_actions(self.trello_id)
      end

      def cards
        trello.boards_cards(self.trello_id)
      end

      def lists
        trello.boards_lists(self.trello_id)
      end
    end

    class User < Sequel::Model
      def board(board_id)
        Board.new(raw: trello.boards(board_id), trello: trello)
      end

      def boards
        trello.members_me_boards
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