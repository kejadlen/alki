require "faraday"
require "faraday_middleware"
require "roda"

class Trello
  attr_reader *%i[ api_key api_secret ]

  def initialize(api_key:, api_secret:)
    @api_key, @api_secret = api_key, api_secret
  end

  class OAuth < Trello
    def request_token(callback:)
      conn = Faraday.new("https://trello.com/1") do |conn|
        conn.request :oauth, consumer_key: self.api_key,
                             consumer_secret: self.api_secret,
                             callback: callback

        conn.response :raise_error

        conn.adapter Faraday.default_adapter
      end

      resp = conn.post("OAuthGetRequestToken")
      Faraday::Utils.parse_query(resp.body)
    end

    def access_token(token:, token_secret:, oauth_verifier:)
      conn = Faraday.new("https://trello.com/1") do |conn|
        conn.request :url_encoded
        conn.request :oauth, consumer_key: self.api_key,
                             consumer_secret: self.api_secret,
                             token: token,
                             token_secret: token_secret

        conn.response :raise_error

        conn.adapter Faraday.default_adapter
      end

      resp = conn.post("OAuthGetAccessToken", oauth_verifier: oauth_verifier)
      Faraday::Utils.parse_query(resp.body)
    end
  end
end

class App < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']

  plugin :json_parser

  route do |r|
    r.root do
      if r.session[:access_token]
        "Success! #{r.session[:access_token]}"
      else
        r.redirect "auth"
      end
    end

    r.on "callback" do
      r.get do
      end

      r.post do
        p r.params
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
