require_relative "test_helper"

require "alki/board_stats"
require "alki/presenters"

class TestBoardPresenter < Alki::Test
  def setup
    board = {}
    board_stats = OpenStruct.new(
        card_list_durations: {"1" => {"some_list_id" => 1*60*60,
                                      "another_list_id" => 30*60*60,
                                      "yet_another_list_id" => 50*60*60},
                              "2" => {"some_list_id" => 0}},
        last_actions: {"2" => "2016-01-13T19:20:55.586Z"},
        averages: {"some_list_id" => 20*60*60,
                   "another_list_id" => 30*60*60,
                   "yet_another_list_id" => 50*60*60},
    )
    lists = {"123" => {"name" => "Waiting for RPI", "id" => "123", "hidden" => false},
             "789" => {"name" => "Waiting for Interview", "id" => "789", "hidden" => false}}
    cards = [{"id" => "1", "name" => "card one", "idList" => "foobar"}, {"id" => "2", "name" => "card two", "idList" => "some_list_id"}]

    @board_presenter = Presenters::Board.new(board, board_stats, lists, cards)
  end

  def test_column_names
    expected = {"123" => "Waiting for RPI", "789" => "Waiting for Interview"}
    assert_equal expected, @board_presenter.column_names
  end

  def test_card_durations
    card_durations = nil
    Time.stub :now, Time.parse("2016-01-15T19:20:55.586Z") do
      card_durations = @board_presenter.card_durations
    end

    assert_equal "< 1 day", card_durations["card one"]["some_list_id"]
    assert_equal "1 day", card_durations["card one"]["another_list_id"]
    assert_equal "2 days", card_durations["card one"]["yet_another_list_id"]
    assert_equal "2 days", card_durations["card two"]["some_list_id"]
  end

  def test_averages
    averages = nil
    Time.stub :now, Time.parse("2016-01-16T19:20:55.586Z") do
      averages = @board_presenter.averages
    end

    assert_equal "< 1 day", averages["some_list_id"]
    assert_equal "1 day", averages["another_list_id"]
    assert_equal "2 days", averages["yet_another_list_id"]
  end
end
