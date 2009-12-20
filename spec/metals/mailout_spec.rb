require 'spec_helper'  

class TestMailoutApp < Mailout::App
  enable :sessions
end

describe Mailout do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  def app
    TestMailoutApp
  end

  before do
    @account = Factory(:account)
    
    # Test doubles for authlogic
    @user = mock("user")
    @user.should_receive(:has_role?).with("staff", @account).and_return(true)
    @session = mock("user_session")
    @session.stub!(:user).and_return(@user)
    UserSession.stub!(:find).and_return(@session)
  end
  
  describe "mailchimp-api powered mailouts" do
    before do
      @mailer = mock("mailer")
      Hominid::Base.stub!(:new).and_return(@mailer)
    end
    
    describe "without a valid api key in your account settings" do
      
      describe "any request" do
        it "should display the activation form" do
          get "/accounts/#{@account.id}/mailouts"
          last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts/activate\"]")        
        end
      end
      
      describe "POST to /accounts/:id/mailouts/activate" do
        
        describe "with a valid api key" do
          it "should activate the account" do
            @mailer.should_receive(:account_details)
            post "/accounts/#{@account.id}/mailouts/activate", :mailchimp_api_key => "this_is_an_valid_api_key"
          
            last_response.should be_redirect
          end
        end
        
        describe "with an invalid api key" do
          it "should not activate the account" do
            @mailer.should_receive(:account_details).and_raise("HTTP-Error: 404 Not Found")
            post "/accounts/#{@account.id}/mailouts/activate", :mailchimp_api_key => "this_is_an_invalid_api_key"
            
            last_response.body.should include("Sorry, that wasn't a valid api key")
            last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts/activate\"]")
          end
        end
        
      end
      
    end
    
    describe "with a valid api key in your account settings" do
      before do
        @account.should_receive(:settings).and_return({'mailchimp_api_key' => 'this_is_a_valid_api_key'})
        Account.stub!(:find).and_return(@account)
      end

      describe "GET to /accounts/:id/mailouts" do
        it "should display all campaigns from Mailchimp" do
          @mailer.should_receive(:campaigns).and_return(Array.new)
          get "/accounts/#{@account.id}/mailouts"
          last_response.should be_ok
        end
      end

      describe "GET to /accounts/:id/mailouts/new" do
        before do
          @articles = (1..5).collect { Factory(:published_article, :account => @account) }
        end
        
        describe "when no lists exist" do
          it "should direct users to Mailchimp to create a list" do
            @mailer.should_receive(:lists).and_return([])
            get "/accounts/#{@account.id}/mailouts/new"

            last_response.body.should include("create a list")
          end
        end
        
        describe "when no templates exist" do
          it "should direct users to create an email template" do
            @mailer.should_receive(:lists).and_return([{'id' => 'list_id_1', 'name' => 'Test list name #1'}, {'id' => 'list_id_2', 'name' => 'Test list name #2'}])
            get "/accounts/#{@account.id}/mailouts/new"
            
            last_response.body.should include("create a mailout template")
          end
        end
        
        describe "when lists and templates exist" do
          before do
            @lists = [{'id' => 'list_id_1', 'name' => 'Test list name #1'}, {'id' => 'list_id_2', 'name' => 'Test list name #2'}]
            @email_templates = (1..3).collect { Factory(:email_template, :account => @account) }
            @mailer.should_receive(:lists).and_return(@lists)
            get "/accounts/#{@account.id}/mailouts/new"
          end
          
          it "should display the mailout form" do
            last_response.should be_ok
            last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts\"]")
          end

          it "should display most recently published articles for mailout inclusion" do
            last_response.body.should have_selector("ol#articles")
            for article in @articles
              last_response.body.should have_selector("li#article_#{article.id}")
            end
          end

          it "should display email template names for selection" do
            @email_templates.each { |e| last_response.body.should have_selector("option[value=\"#{e.id}\"]") }
          end
          
          it "should display list names for selection" do
            @lists.each { |list| last_response.body.should include(list['name']) }
          end
        end
      end

      describe "POST to /accounts/:id/mailouts" do
        before do
          @articles = (1..5).collect { Factory(:published_article, :account => @account) }
          @article_ids = @articles.collect { |a| a.id.to_s }
          @email_template = Factory(:email_template_with_articles, :account => @account)
        end

        it "should create an unsent mailout" do
          Article.should_receive(:find).with(@article_ids).and_return(@articles)

          # This is long, but it's the Hominid api spec
          @mailer.should_receive(:create_campaign).with('regular', {
                  :list_id => 'c18292dd69', 
                  :from_email => "test@example.com", 
                  :from_name => "test name", 
                  :subject => "A test", 
                  :to_email => "totest@example.com" }, { 
                  :html => @email_template.render_html('account' => @account, 'articles' => @articles), 
                  :text => @email_template.render_plaintext('account' => @account, 'articles' => @articles) })
          post "/accounts/#{@account.id}/mailouts", :mailout => { :from_email => "test@example.com", :name => "test name", :subject => "A test", :to_email => "totest@example.com", :articles => @article_ids, :template_id => @email_template.id }
          last_response.should be_redirect
        end
      end

      describe "GET to /accounts/:id/mailouts/:mailout" do
        before do
          @campaign = mock("campaign")
          @campaign.stub!(:[])
          @sample_content = {"html" => "<h1>HTML sample email test</h1>"}
          @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
          @mailer.should_receive(:content).and_return(@sample_content)
          get "/accounts/#{@account.id}/mailouts/sample_id"
        end

        it "should display a preview of the mailout" do
          last_response.body.should include(@sample_content["html"])
        end
        
        it "should display a send button for unsent mailout" do
          @campaign['send_time'].to_s.should == ""
          last_response.body.should have_selector("input[value=\"Send\"]")
        end
      end

      describe "DELETE to /accounts/:id/mailouts/:mailout" do    
        it "should delete the mailout" do
          @mailer.should_receive(:delete).with("sample_id").and_return(true)
          delete "/accounts/#{@account.id}/mailouts/sample_id"
          last_response.should be_redirect
        end
      end

      describe "sending mailouts" do
        
        describe "POST to /accounts/:id/mailouts/:mailout/send" do
          before do
            @campaign = mock("campaign")
          end

          it "should send an unsent mailout" do
            @campaign.should_receive(:[]).with('id').and_return("sample_id")
            @campaign.should_receive(:[]).with('emails_sent').and_return(0)
            @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
            @mailer.should_receive(:send)

            post "/accounts/#{@account.id}/mailouts/sample_id/send"      
          end

          it "should not resend an already sent mailout" do
            @campaign.stub!(:[]).and_return(1)
            @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
            @mailer.should_not_receive(:send)

            post "/accounts/#{@account.id}/mailouts/sample_id/send"
          end
        end

        describe "POST to /accounts/:id/mailouts/:mailout/send_test" do
          it "should send a test email for an unsent mailout" do
            @campaign = mock("campaign")
            @campaign.should_receive(:[]).with('id').twice.and_return("sample_id")
            @campaign.should_receive(:[]).with('emails_sent').and_return(0)

            @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
            @mailer.should_receive(:send_test).with("sample_id", ["test@test.com", "retest@retest.org"], "html")

            post "/accounts/#{@account.id}/mailouts/sample_id/send_test", :emails => "test@test.com,retest@retest.org"
          end
        end
        
      end

    end
  end
  
  describe "email templates for mailouts" do

    describe "GET to /account/:id/mailouts/templates" do
      before do
        @email_templates = (1..3).collect{ Factory(:email_template, :account => @account) }
        get "/accounts/#{@account.id}/mailouts/templates"
      end

      it "should display a list of email templates" do
        last_response.should be_ok
        @email_templates.each do |template|
          last_response.body.should include(template.name)
        end
      end 
    end

    describe "GET to /accounts/:id/mailouts/templates/new" do
      it "should display the mailout form" do
        get "/accounts/#{@account.id}/mailouts/templates/new"

        last_response.should be_ok
        last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts/templates\"]")
      end
    end

    describe "POST to /accounts/:id/mailouts/templates" do
      it "should create a template with valid attributes" do
        template_attributes = { :name => "Test template" }

        post "/accounts/#{@account.id}/mailouts/templates", :template => template_attributes
        last_response.should be_redirect
      end

      it "should not create a template if vaild attributes aren't supplied" do
        post "/accounts/#{@account.id}/mailouts/templates"
        last_response.body.should include("Error saving this template. Maybe it needs a name?")
      end
    end

    describe "GET to /accounts/:id/mailouts/templates/:template/edit" do
      it "should display the template edit form" do
        @email_template = Factory(:email_template, :account => @account)
        get "/accounts/#{@account.id}/mailouts/templates/#{@email_template.id}/edit"

        last_response.should be_ok
        last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts/templates/#{@email_template.id}\"]")
      end
    end

    describe "PUT to /accounts/:id/mailouts/templates/:template" do
      before do
        @email_template = Factory(:email_template, :account => @account) 
      end

      it "should update a template with valid attributes" do
        template_attributes = { :name => "Test template" }

        put "/accounts/#{@account.id}/mailouts/templates/#{@email_template.id}", :template => template_attributes
        last_response.should be_redirect
      end
    end

    describe "DELETE to /accounts/:id/mailouts/templates/:template" do
      it "should delete the template" do
        @email_template = Factory(:email_template, :account => @account )
        delete "/accounts/#{@account.id}/mailouts/templates/#{@email_template.id}"
        @account.email_templates.should be_empty
      end
    end
    
  end  
end