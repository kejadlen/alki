require_relative "test_helper"

require "alki/models"

class TestBoard < Minitest::Test
  DAYS = 24*60*60

  def setup
    trello = Object.new
    @board = Models::Board.new(raw: {"board_id" => "a_board_id", "name" => "Some Board"}, trello: trello)

    def trello.boards_actions(*)
      [
          {"type" => "createCard", "date" => "2016-01-01T01:00:00.000Z", "data" => {"card" => {"id" => "1"}}},
          {"type" => "updateCard", "date" => "2016-01-02T01:00:00.000Z", "data" => {"old" => {"idList" => "some_list_id"},
                                                                                    "card" => {"id" => "1"}}},
          {"type" => "updateCard", "date" => "2016-01-04T01:00:00.000Z", "data" => {"old" => {"idList" => "another_list_id"},
                                                                                    "card" => {"id" => "1"}}},
          {"type" => "updateCard", "date" => "2016-01-07T01:00:00.000Z", "data" => {"old" => {"closed" => false},
                                                                                    "list" => {"id" => "yet_another_list_id"},
                                                                                    "card" => {"id" => "1"}}},
          {"type" => "createCard", "date" => "2016-01-01T01:00:00.000Z", "data" => {"card" => {"id" => "2"}}},
          {"type" => "updateCard", "date" => "2016-01-03T01:00:00.000Z", "data" => {"old" => {"idList" => "some_list_id"},
                                                                                    "card" => {"id" => "2"}}},
      ]
    end
  end

  def test_cycle_times
    cycle_times = @board.card_list_durations
    assert_equal 1*DAYS, cycle_times["1"]["some_list_id"]
    assert_equal 2*DAYS, cycle_times["1"]["another_list_id"]
    assert_equal 3*DAYS, cycle_times["1"]["yet_another_list_id"]
  end

  def test_last_actions
    assert_equal "2016-01-03T01:00:00.000Z", @board.last_actions["2"]
  end

  def test_averages
    assert_equal 2*DAYS, @board.averages["another_list_id"]
    assert_equal 1.5*DAYS, @board.averages["some_list_id"]
  end
end