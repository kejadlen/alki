require "roda"
require "tilt/erubis"

require_relative "db"
require_relative "models"
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
          Models::Action.create(raw: r.params["action"])
          ""
        end
      end

      user = Models::User[r.session[:user_id]]
      r.redirect "auth/sign_in" unless user

      r.root do
        view "index", locals: {user: user}
      end

      r.on "boards" do
        r.is do
          boards = user.boards.map { |board| {id: board["id"],
                                              name: board["name"]} }

          view "boards", locals: {boards: boards}
        end

        r.on ":board_id" do |board_id|
          r.is do
            board_presenter = Presenters::Board.new(user.board(board_id), user.hidden_lists.map(&:list_id))
            view "board", locals: {board_presenter: board_presenter}
          end

          r.post "options" do
            Models::HiddenList.where(user: user, board_id: board_id).delete
            r.params.keys.each do |list_id|
              user.add_hidden_list(board_id: board_id, list_id: list_id)
            end

            r.redirect "/boards/#{board_id}"
          end
        end

      end

      r.on "api" do
        r.get "boards/:board_id" do |board_id|
          board = user.board(board_id)
          lists = board.lists
          averages = board.averages

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
