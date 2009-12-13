require 'sinatra/base'

module ArticleStream 
  class App < Sinatra::Base
    get '/stream' do
      erb "<h1>Loading article stream</h1>"
    end
  end
end