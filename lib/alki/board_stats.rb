class BoardStats
  attr_reader :actions

  def initialize(actions:)
    @actions = actions
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

end
