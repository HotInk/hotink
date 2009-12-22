require 'sinatra/base'
require 'rack-flash'

module Mailout 
  class App < Sinatra::Base
    use Rack::Flash
    
    include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation

    set :views, File.dirname(__FILE__) + '/views'
    enable :methodoverride
     
    def protect_against_forgery?
      false
    end
    
    def load_session 
        @account = Account.find(params[:id])
        halt 404 unless @account
        
        @current_user_session = UserSession.find
        @current_user = @current_user_session.nil? ? nil : @current_user_session.user 
        unless @current_user && (@current_user.has_role?("manager", @account) || @current_user.has_role?('admin'))
          redirect '/user_session/new'
        end
    end
    
    def initialize_mailchimp
      load_session
      api_key = @account.settings['mailchimp_api_key']
      halt 200, erb(:activate) unless api_key
      @mailchimp = Hominid::Base.new({:api_key => api_key })
    end
    
    helpers do
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper
      
      def current_user
        @current_user
      end
    end
    
    ## Mailout templates
    
    get "/accounts/:id/mailouts/templates" do
      load_session
      @email_templates = @account.email_templates
      erb :email_templates
    end 
    
    get "/accounts/:id/mailouts/templates/new" do
      load_session
      @email_template = @account.email_templates.build
      erb :new_email_template
    end
    
    post "/accounts/:id/mailouts/templates" do
      load_session
      @email_template = @account.email_templates.create(params[:template])
      if @email_template.new_record?
        flash[:notice] = "Error saving this template. Maybe it needs a name?"
        erb :new_email_template
      else
        flash[:notice] = "Template successfully created"
        redirect "/accounts/#{@account.id}/mailouts/templates"
      end       
    end 
    
    get "/accounts/:id/mailouts/templates/:template/edit" do
      load_session
      @email_template = @account.email_templates.find(params[:template])
      erb :edit_email_template
    end
    
    put "/accounts/:id/mailouts/templates/:template_id" do
      load_session
      @email_template = @account.email_templates.find(params[:template_id])
      if @email_template.update_attributes(params[:template])
        flash[:notice] = "Template successfully updated"
        redirect "/accounts/#{@account.id}/mailouts/templates"
      else
        flash[:notice] = "Error saving this template. Maybe it needs a name?"
        erb :edit_email_template
      end
    end
    
    delete '/accounts/:id/mailouts/templates/:template' do
      load_session
      @email_template = @account.email_templates.find(params[:template])
      @email_template.destroy
      flash[:notice] = "Template destroyed."
      redirect "/accounts/#{@account.id}/mailouts/templates"
    end
    
    ## Activation
    
    post '/accounts/:id/mailouts/activate' do
      begin
        load_session
        @mailchimp = Hominid::Base.new({:api_key => params[:mailchimp_api_key] })
        
        # Key check will raise RuntimeError (404) if the api key is invalid
        key_check = @mailchimp.account_details
        @account.settings['mailchimp_api_key'] = params[:mailchimp_api_key]
        @account.save
        
        flash[:notice] = "Account successfully activated"
        redirect "/accounts/#{@account.id}/mailouts"
      rescue RuntimeError => e
        flash[:notice] = "Sorry, that wasn't a valid api key. Mailchimp couldn't recognize it. Of course, It's possible that Mailchimp is temporarily unavailable. If you're sure you have a valid key, try activating again later. Mailchimp should be back to normal soon."
        erb :activate
      end
    end

    ## Mailouts

    get '/accounts/:id/mailouts' do
      initialize_mailchimp
      @campaigns = @mailchimp.campaigns
      erb :mailouts
    end
    
    post '/accounts/:id/mailouts' do
      initialize_mailchimp
      @email_template = @account.email_templates.find(params[:mailout][:template_id])
      @articles = Article.find(params[:mailout][:articles])
      @mailchimp.create_campaign('regular', 
            { :list_id => params[:mailout][:list_id], 
              :from_email => params[:mailout][:from_email], 
              :from_name => params[:mailout][:name], 
              :subject => params[:mailout][:subject], 
              :to_email => params[:mailout][:to_email] }, 
            { :html => @email_template.render_html('account' => @account, 'articles' => @articles, 'note' => params[:mailout][:note]), 
              :text => @email_template.render_plaintext('account' => @account, 'articles' => @articles, 'note' => params[:mailout][:note]) }
      )
      redirect "/accounts/#{@account.id}/mailouts"
    end
    
    get '/accounts/:id/mailouts/new' do
      initialize_mailchimp
      
      # Check for lists
      @lists = @mailchimp.lists
      halt 200, erb(:create_list) if @lists.empty?

      # Check for templates
      @email_templates = @account.email_templates
      halt 200, erb(:create_email_template) if @email_templates.empty?
      
      @articles = @account.articles.status_matches("published").by_published_at(:desc).paginate(:page => 1, :per_page => 6)
      erb :new_mailout
    end

    get '/accounts/:id/mailouts/articles' do
      load_session
      @articles = @account.articles.status_matches("published").by_published_at(:desc).paginate(:page => params[:page], :per_page => 6)
      erb :articles, :layout => false
    end
    
    get '/accounts/:id/mailouts/:mailout' do
      initialize_mailchimp
      @campaign = @mailchimp.find_campaign_by_id(params[:mailout])
      @list = @mailchimp.find_list_by_id(@campaign['list_id'])
      @content = @mailchimp.content(@campaign['id'])
      erb :mailout
    end
    
    delete '/accounts/:id/mailouts/:mailout' do
      initialize_mailchimp
      @mailchimp.delete(params[:mailout])
      redirect "/accounts/#{@account.id}/mailouts"
    end
    
    ## Mailouts - send actions
    
    post '/accounts/:id/mailouts/:mailout/send' do
      begin
        initialize_mailchimp
        @campaign = @mailchimp.find_campaign_by_id(params[:mailout])
        @mailchimp.send(@campaign['id']) unless @campaign['emails_sent'].to_i > 0
      rescue
      ensure
        flash[:notice] = "Mailout sent"
        redirect "/accounts/#{@account.id}/mailouts"
      end
    end
    
    post '/accounts/:id/mailouts/:mailout/send_test' do
        initialize_mailchimp
        @campaign = @mailchimp.find_campaign_by_id(params[:mailout])
        @mailchimp.send_test(@campaign['id'], params[:emails].split(","), "html") unless @campaign['emails_sent'].to_i > 0
        flash[:test_email_notice] = "Test email sent to #{params[:emails]}"
        redirect "/accounts/#{@account.id}/mailouts/#{@campaign['id']}"
    end
  end
end