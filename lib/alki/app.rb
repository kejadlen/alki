require "roda"

require_relative "db"
require_relative "trello"

module Alki
  class App < Roda
    use Rack::Session::Cookie, :secret => ENV["SECRET"]

    plugin :head
    plugin :json_parser

    route do |r|
      user = Models::User[r.session[:user_id]]

      r.root do
        if user
          "Success! User ID: #{user.id}"
        else
          r.redirect "auth"
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

      r.on "auth" do
        trello = Trello::OAuth.new(api_key: ENV["TRELLO_KEY"], api_secret: ENV["TRELLO_SECRET"])

        r.is do
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
    end
  end
end
