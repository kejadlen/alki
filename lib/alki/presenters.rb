module Alki
  module Presenters
    class Board
      SECONDS_PER_DAY = 24*60*60

      attr_reader :board, :board_stats, :lists, :cards, :stats

      def initialize(board, board_stats, lists, cards, stats)
        @board, @board_stats, @cards, @stats = board, board_stats, cards, stats
        @lists = Hash[lists.sort_by { |_, list| list["pos"] }]
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

        card_list_durations = self.board_stats.card_list_durations

        current_lists = Hash[cards.values.map { |card| [card["id"], card["idList"]] }]
        self.board_stats.last_actions.each do |card_id, date|
          card_list_durations[card_id][current_lists[card_id]] += Time.now - Time.parse(date)
        end

        @card_durations = card_list_durations.each.with_object(Hash.new { |h, k| h[k] = {} }) do |(card_id, row), card_durations|
          row.each.with_object(card_durations) do |(list_id, duration), card_durations|
            card_name = cards[card_id]["name"]
            card_durations[card_name][list_id] = self._format_duration(duration)
          end
        end
      end

      def averages
        self.board_stats.averages.each.with_object({}) do |(list_id, duration), averages|
          averages[list_id] = self._format_duration(duration)
        end
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
