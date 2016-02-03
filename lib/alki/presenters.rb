module Alki
  module Presenters
    class Board
      SECONDS_PER_DAY = 24*60*60

      attr_reader :board, :lists, :cards, :stats

      def initialize(board, lists, cards, stats)
        @board, @cards, @stats = board, cards, stats
        @lists = lists.sort_by { |list| list["pos"] }
      end

      def wait_time(card_id, list_id)
        self._format_duration(self.stats.wait_times[card_id][list_id])
      end

      def average(list_id)
        self.averages[list_id]
      end

      def card_durations
        return @card_durations if defined?(@card_durations)

        cards = Hash[self.cards.map { |card| [card["id"], card] }]

        @card_durations = Hash.new {|h,k| h[k] = {} }
        self.stats.wait_times.each do |card_id, history|
          history.each do |list_id, duration|
            card_name = cards[card_id]["name"]
            card_durations[card_name][list_id] = self._format_duration(duration)
          end
        end
        @card_durations
      end

      def averages
        self.stats.averages.each.with_object({}) do |(list_id, duration), averages|
          averages[list_id] = self._format_duration(duration)
        end
      end

      def visible_lists
        @lists.reject { |list| list["hidden"] }
      end

      def _format_duration(duration)
        return "" if duration.nil?

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
