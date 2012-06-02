require 'sinatra/base'

class Andy::App < ::Sinatra::Base
  get '/' do
    "Hello, I'm Andy."
  end
end
