require 'sinatra/base'

module Mailout 
  class App < Sinatra::Base
    include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation

    set :views, File.dirname(__FILE__) + '/views'

    API_KEY = 'e03757750894d3afb19d93edf0bf9421-us1'
    
    def initialize_mailchimp
      @account = Account.find(params[:id])
      halt 404 unless @account
      @mailchimp = Hominid::Base.new({:api_key => API_KEY })
    end

    get '/accounts/:id/mailouts' do
      initialize_mailchimp
      @campaigns = @mailchimp.campaigns
      erb :mailouts
    end
    
    get '/accounts/:id/mailouts/new' do
      initialize_mailchimp
      erb :new_mailout
    end
    
    get '/accounts/:id/mailouts/:mailout' do
      initialize_mailchimp
      @campaign = @mailchimp.find_campaign_by_id(params[:mailout])
      erb :mailout
    end

  end
end