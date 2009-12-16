require 'sinatra/base'

module Mailout 
  class App < Sinatra::Base
    include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation

    set :views, File.dirname(__FILE__) + '/views'

    API_KEY = 'e03757750894d3afb19d93edf0bf9421-us1'
    
    def initialize_mailchimp
      @mailchimp = Hominid::Base.new({:api_key => API_KEY })
    end

    get '/accounts/:id/mailouts' do
      initialize_mailchimp
      @campaigns = @mailchimp.campaigns
      erb :mailouts
    end

  end
end