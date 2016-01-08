require "faraday"
require "faraday_middleware"
require "roda"

require_relative "trello"

module Alki
  class App < Roda
    use Rack::Session::Cookie, :secret => ENV['SECRET']

    plugin :head
    plugin :json_parser

    route do |r|
      r.root do
        if r.session[:access_token]
          "Success! #{r.session[:access_token]}"
        else
          r.redirect "auth"
        end
      end

      r.is "callback" do
        r.get do
          ""
        end

        r.post do
          p r.params
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
          url << "?oauth_token=#{request_token["oauth_token"]}&name=Hello%20World!"
          r.redirect url
        end

        r.get "callback" do
          token = r.params["oauth_token"]
          token_secret = r.session.delete(:token_secret)
          oauth_verifier = r.params["oauth_verifier"]

          access_token = trello.access_token(token: token, token_secret: token_secret,
                                             oauth_verifier: oauth_verifier)

          r.session[:access_token] = access_token

          r.redirect "/"
        end

        r.get "sign_out" do
          r.session.delete(:access_token)
          r.redirect "/"
        end
      end
    end
  end
end
