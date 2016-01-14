require_relative "test_helper"

require "alki/presenters"

class TestBoardPresenter < Minitest::Test
  def setup
    board = OpenStruct.new(
        lists: [{"name" => "Waiting for RPI"},
                {"name" => "Waiting for Interview"}],
        card_list_durations: {"1" => {"some_list_id" => 1*60*60,
                                      "another_list_id" => 30*60*60,
                                      "yet_another_list_id" => 50*60*60},
                              "2" => {}},
        last_actions: {"2" => "2016-01-13T19:20:55.586Z"},
        cards: [{"id" => "1", "name" => "card one", "idList" => "foobar"},
                {"id" => "2", "name" => "card two", "idList" => "some_list_id"}],
        averages: {"some_list_id" => 20*60*60,
                   "another_list_id" => 30*60*60,
                   "yet_another_list_id" => 50*60*60},
    )

    @board_presenter = Presenters::Board.new(board)
  end

  def test_column_names
    assert_equal ["Name", "Waiting for RPI", "Waiting for Interview"], @board_presenter.column_names
  end

  def test_card_durations
    cd = nil
    Time.stub :now, Time.parse("2016-01-15T19:20:55.586Z") do
      cd = @board_presenter.card_durations
    end

    assert_equal "< 1 day", cd["card one"]["some_list_id"]
    assert_equal "1 day", cd["card one"]["another_list_id"]
    assert_equal "2 days", cd["card one"]["yet_another_list_id"]
    assert_equal "2 days", cd["card two"]["some_list_id"]
  end

  def test_averages
    cd = nil
    Time.stub :now, Time.parse("2016-01-16T19:20:55.586Z") do
      cd = @board_presenter.card_durations
    end

    assert_equal "< 1 day", cd["Average"]["some_list_id"]
    assert_equal "1 day", cd["Average"]["another_list_id"]
    assert_equal "2 days", cd["Average"]["yet_another_list_id"]
  end
end