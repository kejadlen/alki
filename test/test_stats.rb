require_relative "test_helper"

require "alki/stats"

class TestStats < Alki::Test
  def setup
    actions = [
      {"type" => "createCard",
       "date" => "2016-01-01T01:00:00.000Z",
       "data" => {"card" => {"id" => "1"}}},
      {"type" => "updateCard",
       "date" => "2016-01-02T01:00:00.000Z",
       "data" => {"listBefore" => {"id" => "some_list_id"}, "card" => {"id" => "1"}}},
      {"type" => "updateCard",
       "date" => "2016-01-04T01:00:00.000Z",
       "data" => {"listBefore" => {"id" => "another_list_id"}, "card" => {"id" => "1"}}},
      {"type" => "updateCard",
       "date" => "2016-01-07T01:00:00.000Z",
       "data" => {"listBefore" => {"closed" => false},
                  "list" => {"id" => "yet_another_list_id"},
                  "card" => {"id" => "1"}}},
      {"type" => "createCard",
       "date" => "2016-01-01T01:00:00.000Z",
       "data" => {"card" => {"id" => "2"}}},
      {"type" => "updateCard",
       "date" => "2016-01-03T01:00:00.000Z",
       "data" => {"listBefore" => {"id" => "some_list_id"},
                  "listAfter" => {"id" => "yet_another_list_id"},
                  "card" => {"id" => "2"}}},
    ]
    @card = Stats.new(actions: actions, time: Time.parse("2016-01-08"))
  end

  def test_averages
    assert_equal({ "some_list_id" => 129_600,
                   "another_list_id" => 172_800,
                   "yet_another_list_id" => 358_200 }, @card.averages)
  end

  def test_wait_times
    assert_equal({ "some_list_id" => 86_400,
                   "another_list_id" => 172_800,
                   "yet_another_list_id" => 259_200 }, @card.wait_times["1"])
    assert_equal({ "some_list_id" => 172_800,
                   "yet_another_list_id" => 457_200 }, @card.wait_times["2"])
  end
end
