task :console do
  require "dotenv"
  Dotenv.load(".private.envrc")

  require_relative "trello"
  trello = Trello::Authed.new(api_key: ENV["TRELLO_KEY"],
                              api_secret: ENV["TRELLO_SECRET"],
                              access_token: ENV["ACCESS_TOKEN"],
                              access_token_secret: ENV["ACCESS_TOKEN_SECRET"])

  require "pry"
  binding.pry
end
