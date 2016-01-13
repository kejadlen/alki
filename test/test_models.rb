require_relative "test_helper"

require "alki/models"

class TestBoard < Minitest::Test
  def setup
    @trello = Object.new
    @board = Models::Board.new(raw: { "board_id" => "a_board_id", "name" => "Some Board" }, trello: @trello)
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
  end
end