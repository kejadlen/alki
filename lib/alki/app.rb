require "roda"
require "tilt/erubis"

require_relative "board_stats"
require_relative "db"
require_relative "presenters"
require_relative "trello"

module Alki
  SECONDS_PER_DAY = 24*60*60

  class App < Roda
    use Rack::Session::Cookie, :secret => ENV["SECRET"]

    opts[:root] = File.expand_path("..", __FILE__)

    plugin :all_verbs
    plugin :head
    plugin :json_parser
    plugin :render, escape: true
    plugin :static, ["/js"]

    route do |r|
      r.on "auth" do
        trello = Trello::OAuth.new(api_key: ENV["TRELLO_KEY"], api_secret: ENV["TRELLO_SECRET"])

        r.get "sign_in" do
          callback = "http://#{r.host_with_port}/auth/callback"
          request_token = trello.request_token(callback: callback)

          r.session[:token_secret] = request_token["oauth_token_secret"]

          url = "https://trello.com/1/OAuthAuthorizeToken"
          url << "?oauth_token=#{request_token["oauth_token"]}&name=Alki%20Beach"
          r.redirect url
        end

        r.get "callback" do
          token = r.params["oauth_token"]
          token_secret = r.session.delete(:token_secret)
          oauth_verifier = r.params["oauth_verifier"]

          access_token = trello.access_token(token: token, token_secret: token_secret,
                                             oauth_verifier: oauth_verifier)

          oauth_token = access_token["oauth_token"]
          oauth_token_secret = access_token["oauth_token_secret"]

          authed = Trello::Authed.new(api_key: ENV["TRELLO_KEY"],
                                      api_secret: ENV["TRELLO_SECRET"],
                                      access_token: oauth_token,
                                      access_token_secret: oauth_token_secret)
          me = authed.members_me

          user = Models::User.find_or_create(trello_id: me["id"])
          user.update(access_token: oauth_token, access_token_secret: oauth_token_secret)

          r.session[:user_id] = user.id

          r.redirect "/"
        end

        r.get "sign_out" do
          r.session.delete(:user_id)
          r.redirect "/"
        end
      end

      r.is "callback" do
        r.get do
          ""
        end

        r.post do
          DB[:actions].insert(raw: r.params["action"])
          ""
        end
      end

      user = DB[:users].first(id: r.session[:user_id])
      r.redirect "auth/sign_in" unless user
      trello = Trello::Authed.new(api_key: ENV["TRELLO_KEY"],
                                  api_secret: ENV["TRELLO_SECRET"],
                                  access_token: user[:access_token],
                                  access_token_secret: user[:access_token_secret])

      r.root do
        view "index", locals: {user: user}
      end

      r.on "boards" do
        r.is do
          boards = trello.members_me_boards.map { |board| {id: board["id"], name: board["name"]} }
          view "boards", locals: {boards: boards}
        end

        r.on ":board_id" do |board_id|
          r.is do
            board = trello.boards(board_id)
            actions = trello.boards_actions(board_id)
            board_stats = BoardStats.new(actions: actions)
            lists = Hash[trello.boards_lists(board_id).map { |list| [list["id"], list] }]
            cards = trello.boards_cards(board_id)

            hidden_list_ids = DB[:hidden_lists].where(user_id: user[:id]).map(:list_id)
            lists.each do |list_id, list|
              list["hidden"] =  hidden_list_ids.include?(list_id)
            end

            board_presenter = Presenters::Board.new(board, board_stats, lists, cards)
            view "board", locals: {board_presenter: board_presenter}
          end

          r.post "options" do
            DB[:hidden_lists].where(user_id: user[:id], board_id: board_id).delete
            r.params.keys.each do |list_id|
              DB[:hidden_lists].insert(user_id: user[:id], board_id: board_id, list_id: list_id)
            end

            r.redirect "/boards/#{board_id}"
          end
        end

      end

      r.on "api" do
        r.get "boards/:board_id" do |board_id|
          actions = trello.boards_actions(board_id)
          board_stats = BoardStats.new(actions: actions)
          lists = trello.boards_lists(board_id)
          averages = board_stats.averages

          data = lists.each.with_object({lists: []}) do |list, data|
            data[:lists] << {id: list["id"], name: list["name"], average_duration: averages[list["id"]]}
          end

          data[:board_id] = board_id
          JSON.dump(data)
        end
      end

      r.on "webhook" do
        r.delete ":webhook_id" do |webhook_id|
          user.delete_webhook(webhook_id)
          ""
        end

        r.post do
          user.add_webhook(board_id: r.params["board_id"], callback_url: "http://#{r.host_with_port}/callback")
          ""
        end
      end
    end
  end
end
