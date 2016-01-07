require "roda"

class App < Roda
  use Rack::Session::Cookie, :secret => ENV['SECRET']

  route do |r|
    r.root do
      "Hello World!"
    end
  end
end
