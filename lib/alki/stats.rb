module Alki
  class Stats
    class Action < Struct.new(:time, :list_id)
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

    def card_ids
      self._histories.keys
    end

    def list_ids
      self._histories.values.flatten.map(&:list_id).uniq.compact
    end

    def wait_times
      return @wait_times if defined?(@wait_times)

      @wait_times = Hash.new { |h,k| h[k] = {} }
      self._histories.each do |card_id, history|
        history += [ Action.new(self.time, nil) ] unless history.last.list_id.nil?
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
        @histories[card_id] = actions.sort_by { |action| action["date"] }.map do |action|
          date = action["date"]
          list_id = case action["type"]
                      when "createCard"
                        action["data"]["list"]["id"]
                      when "updateCard"
                        list = action["data"]["listAfter"]
                        list && list["id"] # nil if the card is closed
                      else
                        raise "Unexpected type \"#{type}\""
                    end
          Action.new(date, list_id)
        end
      end
      @histories
    end
  end
end
