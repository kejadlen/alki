require "sequel"

require_relative "db"
require_relative "trello"

module Alki
  module Models
    class Board
      attr_reader :raw

      def initialize(raw:, trello:)
        @raw, @trello = raw, trello
      end

      def card_list_durations
        self.actions
            .group_by { |action| action["data"]["card"]["id"] }
            .each.with_object({}) do |(card_id, actions), card_list_durations|
          list_durations = actions.sort_by { |action| action["date"] }
                                  .each_cons(2)
                                  .each.with_object(Hash.new(0)) do |(action_1, action_2), list_durations|
            list_id = action_2["data"]["old"]["idList"] || action_2["data"]["list"]["id"]
            list_durations[list_id] += Time.parse(action_2["date"]) - Time.parse(action_1["date"])
          end
          card_list_durations[card_id] = list_durations
        end
      end

      def last_actions
        self.actions
            .group_by { |action| action["data"]["card"]["id"] }
            .each.with_object(Hash.new { |h, k| h[k] = [] }) do |(card_id, actions), last_actions|
          last_actions[card_id] = actions.map { |action| action["date"] }.max
        end
      end

      def averages
        list_durations = Hash.new { |h, k| h[k] = [] }
        self.card_list_durations.values.each do |durations|
          durations.each do |list_id, duration|
            list_durations[list_id] << duration
          end
        end

        Hash[
            list_durations.map do |list_id, durations|
              [list_id, durations.inject(:+) / durations.length]
            end
        ]
      end

      # Attributes

      def id
        self.raw["id"]
      end

      def name
        self.raw["name"]
      end

      # Trello

      def actions
        return @actions if defined?(@actions)

        @actions = trello.boards_actions(self.id)
      end

      def cards
        trello.boards_cards(self.id)
      end

      def lists
        trello.boards_lists(self.id)
      end

      private

      def trello
        @trello
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

    class Action < Sequel::Model
    end
  end
end