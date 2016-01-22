require "sequel"

require_relative "board_stats"
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
        board_stats.card_list_durations
      end

      def last_actions
        board_stats.last_actions
      end

      def averages
        board_stats.averages
      end

      # Attributes

      def id
        self.raw["id"]
      end

      def name
        self.raw["name"]
      end

      # Trello

      def cards
        trello.boards_cards(self.id)
      end

      def lists
        trello.boards_lists(self.id)
      end

      private

      def board_stats
        return @board_stats if defined?(@board_stats)

        actions = trello.boards_actions(self.id)
        @board_stats = BoardStats.new(actions: actions)
      end

      def trello
        @trello
      end
    end

    class Action < Sequel::Model
    end
  end
end
