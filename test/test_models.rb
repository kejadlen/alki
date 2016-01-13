require_relative "test_helper"

require "alki/models"

module Alki
  class TestCard < Minitest::Test
    def setup
      # @card = Models::Card.new(card_id: "some_card_id", name: "Alice", list_id: "a_list_id", trello: nil)
    end

    def test_wait_time
      actions = [{ "type" => "createCard",
                   "data" => { "card" => { "id" => "1" } },
                   "date" => "2016-01-12T01:00:05.737Z" },
                 { "type" => "updateCard",
                   "data" => { "card" => { "id" => "1" },
                               "listAfter" => { "id"=>"5" }},
                   "date" => "2016-01-14T01:00:05.737Z" },
                 { "type" => "updateCard",
                   "data" => { "card" => { "id" => "1" },
                               "listAfter" => { "id"=>"10" }},
                   "date" => "2016-01-13T01:00:05.737Z" }]
      card = Models::Card.new(card_id: "some_card_id", name: "Alice", list_id: "a_list_id", actions: actions, trello: nil)

      assert_equal Time.parse("2016-01-14T01:00:05.737Z"), card.last_moved
    end
  end

  class TestBoard < Minitest::Test
    def setup
      @trello = Object.new
      @board = Models::Board.new(board_id: "a_board_id", name: "Some Board", trello: @trello)
    end

    def test_cards
      def @trello.boards_actions(*)
        [{ "type" => "createCard", "data" => { "card" => { "id" => "1" }}},
         { "type" => "createCard", "data" => { "card" => { "id" => "2" }}},
         { "type" => "updateCard", "data" => { "card" => { "id" => "2" },
                                               "listAfter" => { "id"=>"56903b61281e96dd0ae060f2" }}}]
      end
      actions = @trello.boards_actions

      def @trello.boards_cards(*)
        [{ "id" => "1", "name" => "one", "idList" => "list_id" },
         { "id" => "2", "name" => "two", "idList" => "list_id" },
         { "id" => "3", "name" => "three", "idList" => "list_id" }]
      end

      cards = @board.cards

      assert_equal 3, cards.size
      assert_equal actions.values_at(0), cards[0].actions

      assert_equal actions.values_at(1, 2), cards[1].actions
    end
  end
end