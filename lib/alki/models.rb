require_relative "trello"

module Alki
  module Models

    class Card
      attr_reader :card_id, :name, :list_id, :actions

      def initialize(card_id:, name:, list_id:, actions:, trello:)
        @card_id, @name, @list_id, @actions, @trello = card_id, name, list_id, actions, trello
      end

      def last_moved
        actions.map {|action| Time.parse(action["date"]) }.max
      end
    end

    class Board
      attr_reader :board_id, :name

      def initialize(board_id:, name:, trello:)
        @board_id, @name, @trello = board_id, name, trello
      end

      def cards
        cards_ids_to_actions = Hash.new {|h,k| h[k] = [] }

        actions = trello.boards_actions(self.board_id)
        actions.select! do |action|
          action["type"] == "createCard" || (action["type"] == "updateCard" && action["data"].has_key?("listAfter"))
        end

        actions.each do |action|
          id = action["data"]["card"]["id"]
          cards_ids_to_actions[id] << action
        end

        trello.boards_cards(self.board_id).map do |card|
          Card.new(card_id: card["id"], name: card["name"], list_id: card["idList"], actions: cards_ids_to_actions[card["id"]], trello: trello)
        end
      end

      def lists
        trello.boards_lists(self.board_id)
      end

      private

      def trello
        @trello
      end
    end

    class User < Sequel::Model
      def board(board_id)
        board = trello.boards(board_id)
        Board.new(board_id: board["id"], name: board["name"], trello: trello)
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