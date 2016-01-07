require "faraday"
require "faraday_middleware"
require "roda"

class Trello
  attr_reader *%i[ key secret ]

  def initialize(key:, secret:)
    @key, @secret = key, secret
  end

  def request_token(callback:)
    conn = Faraday.new("https://trello.com/1") do |conn|
      conn.request :oauth, consumer_key: self.key,
                           consumer_secret: self.secret,
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
      conn.request :oauth, consumer_key: self.key,
                           consumer_secret: self.secret,
                           token: token,
                           token_secret: token_secret

      conn.response :raise_error

      conn.adapter Faraday.default_adapter
    end

    resp = conn.post("OAuthGetAccessToken", oauth_verifier: oauth_verifier)
    Faraday::Utils.parse_query(resp.body)
  end
end

class App < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']

  route do |r|
    r.root do
      if r.session[:access_token]
        "Success! #{r.session[:access_token]}"
      else
        r.redirect "auth"
      end
    end

    r.on "auth" do
      r.is do
        trello = Trello.new(key: ENV["TRELLO_KEY"], secret: ENV["TRELLO_SECRET"])
        callback = "http://#{r.host_with_port}/auth/callback"
        request_token = trello.request_token(callback: callback)

        r.session[:token] = request_token["oauth_token"]
        r.session[:token_secret] = request_token["oauth_token_secret"]

        url = "https://trello.com/1/OAuthAuthorizeToken"
        url << "?oauth_token=#{r.session[:token]}&name=Hello%20World!"
        r.redirect url
      end

      r.get "callback" do
        token = r.session.delete(:token)
        token_secret = r.session.delete(:token_secret)
        oauth_verifier = r.params["oauth_verifier"]

        trello = Trello.new(key: ENV["TRELLO_KEY"], secret: ENV["TRELLO_SECRET"])
        access_token = trello.access_token(token: token, token_secret: token_secret,
                                           oauth_verifier: oauth_verifier)

        r.session[:access_token] = access_token

        r.redirect "/"
      end
    end
  end
end
