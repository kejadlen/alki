module Alki
  class CycleTimes
    attr_reader :cards, :actions
    attr_reader :data

    def initialize(cards:, actions:)
      @cards, @actions = cards, actions
      @data = {}

      calculate!
    end

    def card(card_id)
      self.data[card_id]
    end

    private

    def calculate!
      self.actions.group_by {|action| action["data"]["card"]["id"] }.map do |card_id, actions|
        self.data[card_id] = Hash[
          actions.sort_by {|action| action["date"] }.each_cons(2).map do |action_1, action_2|
            list_id = action_2["data"]["old"]["idList"] || action_2["data"]["list"]["id"]
            [ list_id, Time.parse(action_2["date"]) - Time.parse(action_1["date"]) ]
          end
        ]
      end
    end
  end
end