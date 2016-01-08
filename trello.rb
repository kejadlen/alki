class Trello
  attr_reader *%i[ api_key api_secret ]

  def initialize(api_key:, api_secret:)
    @api_key, @api_secret = api_key, api_secret
  end

  class Trello
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

  class Authed < Trello
    attr_reader *%i[ access_token access_token_secret conn ]

    def initialize(api_key:, api_secret:, access_token:, access_token_secret:)
      super(api_key: api_key, api_secret: api_secret)

      @access_token, @access_token_secret = access_token, access_token_secret

      @conn = Faraday.new("https://trello.com/1") do |conn|
        conn.request :oauth, consumer_key: self.api_key,
                             consumer_secret: self.api_secret,
                             token: self.access_token,
                             token_secret: self.access_token_secret
        conn.request :json

        conn.response :raise_error
        conn.response :json, :content_type => /\bjson$/

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
