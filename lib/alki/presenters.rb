module Alki
  module Presenters
    class Board
      SECONDS_PER_DAY = 24*60*60

      attr_reader :board, :lists

      def initialize(board)
        @board = board

        @lists = self.board.lists.sort_by { |list| list["pos"] }
      end

      def name
        self.board.name
      end

      def column_names
        self.lists.map { |list| list["name"] }
      end

      def card_durations
        cards = self.board.cards
        cards.unshift("id" => "average", "name" => "Average")
        cards = Hash[cards.map { |card| [card["id"], card] }]

        cycle_times = self.board.card_list_durations

        current_lists = Hash[cards.values.map { |card| [card["id"], card["idList"]] }]
        self.board.last_actions.each do |card_id, date|
          cycle_times[card_id][current_lists[card_id]] = Time.now - Time.parse(date)
        end

        cycle_times.each.with_object(Hash.new { |h, k| h[k] = {} }) do |(card_id, row), card_durations|
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