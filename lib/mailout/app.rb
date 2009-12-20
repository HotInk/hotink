require 'sinatra/base'
require 'rack-flash'

module Mailout 
  class App < Sinatra::Base
    use Rack::Flash
    
    include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation

    set :views, File.dirname(__FILE__) + '/views'
    enable :methodoverride
    
    API_KEY = 'e03757750894d3afb19d93edf0bf9421-us1'
    
    def load_session 
        @account = Account.find(params[:id])
        halt 404 unless @account
        
        @current_user_session = UserSession.find
        @current_user = @current_user_session.nil? ? nil : @current_user_session.user 
        unless @current_user && (@current_user.has_role?("staff", @account) || @current_user.has_role?("admin"))
          redirect '/user_session/new'
        end
    end
    
    def initialize_mailchimp
      load_session
      @mailchimp = Hominid::Base.new({:api_key => API_KEY })
    end
    
    helpers do
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
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
            { :list_id => 'c18292dd69', 
              :from_email => params[:mailout][:from_email], 
              :from_name => params[:mailout][:name], 
              :subject => params[:mailout][:subject], 
              :to_email => params[:mailout][:to_email] }, 
            { :html => @email_template.render_html('account' => @account, 'articles' => @articles), 
              :text => @email_template.render_plaintext('account' => @account, 'articles' => @articles) }
      )
      redirect "/accounts/#{@account.id}/mailouts"
    end
    
    get '/accounts/:id/mailouts/new' do
      initialize_mailchimp
      @email_templates = @account.email_templates
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
      @content = @mailchimp.content(@campaign["id"])
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