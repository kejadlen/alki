module Alki
  module Presenters
    class Board
      SECONDS_PER_DAY = 24*60*60

      attr_reader :board, :lists, :hidden_lists

      def initialize(board, hidden_lists)
        @board, @hidden_lists = board, hidden_lists

        @lists = self.board.lists.sort_by { |list| list["pos"] }
      end

      def id
        self.board.id
      end

      def name
        self.board.name
      end

      def column_names
        Hash[self.lists.map { |list| [list["id"], list["name"]] }]
      end

      def card_durations
        cards = self.board.cards
        cards.unshift("id" => "average", "name" => "Average")
        cards = Hash[cards.map { |card| [card["id"], card] }]

        card_list_durations = self.board.card_list_durations

        current_lists = Hash[cards.values.map { |card| [card["id"], card["idList"]] }]
        self.board.last_actions.each do |card_id, date|
          card_list_durations[card_id][current_lists[card_id]] += Time.now - Time.parse(date)
        end

        card_list_durations.each.with_object(Hash.new { |h, k| h[k] = {} }) do |(card_id, row), card_durations|
          row.each.with_object(card_durations) do |(list_id, duration), card_durations|
            card_name = cards[card_id]["name"]
            card_durations[card_name][list_id] = format_duration(duration)
          end
        end
      end

      def averages
        self.board.averages.each.with_object({}) do |(list_id, duration), averages|
          averages[list_id] = format_duration(duration)
        end
      end

      private

      def format_duration(duration)
        days = duration / SECONDS_PER_DAY
        case days.floor
          when 0
            "< 1 day"
          when 1
            "1 day"
          else
            "#{days.floor} days"
        end
      end
    end
  end
end
