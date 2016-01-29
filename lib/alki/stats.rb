module Alki
  class Stats
    class Timestamp < Struct.new(:time, :list_id)
      def initialize(time, *args)
        super

        self.time = Time.parse(time) unless Time === time
      end
    end

    attr_reader :actions, :time

    def initialize(actions:, time: nil)
      time ||= Time.now
      @actions, @time = actions, time
    end

    def averages
      return @averages if defined?(@averages)

      list_wait_times = Hash.new { |h,k| h[k] = [] }
      self.wait_times.each do |_, wait_times|
        wait_times.each do |list_id, duration|
          list_wait_times[list_id] << duration
        end
      end

      Hash[
        list_wait_times.map { |list_id, durations| [ list_id,
                                                     durations.inject(:+) / durations.size ]}
      ]
    end

    def wait_times
      return @wait_times if defined?(@wait_times)

      @wait_times = Hash.new { |h,k| h[k] = {} }
      self._histories.each do |card_id, history|
        history += [ Timestamp.new(self.time, nil) ] unless history.last.list_id.nil?
        history.each_cons(2) do |pre, post|
          @wait_times[card_id][pre.list_id] = post.time - pre.time
        end
      end
      @wait_times
    end

    def _histories
      return @histories if defined?(@histories)

      @histories = {}
      actions.group_by { |action| action["data"]["card"]["id"] }.each do |card_id, actions|
        sorted_actions = actions.sort_by { |action| action["date"] }
        history = sorted_actions.each_cons(2).map do |action_1, action_2|
          list_id = action_2["data"]["listBefore"]["id"] || action_2["data"]["list"]["id"] 
          [ action_1["date"], list_id ]
        end

        current_action = sorted_actions.last
        list_id = current_action["data"]["listAfter"]["id"] rescue nil
        history << [ current_action["date"], list_id ]

        @histories[card_id] = history.map { |date, list_id| Timestamp.new(date, list_id) }
      end
      @histories
    end
  end
end
