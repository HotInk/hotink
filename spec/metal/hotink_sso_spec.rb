require 'spec_helper'

class TestApp < Sinatra::Base
  enable :sessions
  use HotinkSso
end

describe HotinkSso do
  include Rack::Test::Methods    
  include Webrat::Matchers

  def app
    TestApp
  end
  
  describe "visiting /sso" do
    
    before(:each) do
        @user = User.create!(Factory.attributes_for(:user))
        @consumer = Factory(:sso_consumer)
        @identity_url = "http://example.org/sso/users/#{@user.id}"
    end
    
    it "should throw a bad request if there aren't any openid params" do
      get '/sso'
      last_response.status.should eql(400)
    end
    
    describe "with openid mode of associate" do
      it "should respond with Diffie Hellman data in kv format" do
        session = OpenID::Consumer::AssociationManager.create_session("DH-SHA1")
        params = {"openid.ns" => 'http://specs.openid.net/auth/2.0',
                   "openid.mode" => "associate",
                   "openid.session_type" => 'DH-SHA1',
                   "openid.assoc_type" => 'HMAC-SHA1',
                   "openid.dh_consumer_public"=> session.get_request['dh_consumer_public']}

        get "/sso", params

        last_response.should be_an_openid_associate_response(session)
      end
    end
      
    describe "with openid mode of checkid_setup" do
      describe "when authenticated" do
        it "should redirect to the consumer app" do
          params = {
              "openid.ns" => "http://specs.openid.net/auth/2.0",
              "openid.mode" => "checkid_setup",
              "openid.return_to" => @consumer.url,
              "openid.identity" => @identity_url,
              "openid.claimed_id" => @identity_url
          }

          sso_login_as(@user)
          get "/sso", params
          last_response.status.should == 302
          last_response.should be_a_redirect_to_the_consumer(@consumer, @user)
        end

        describe "but attempting to access from an untrusted consumer" do
          it "should cancel the openid request" do
            params = {
              "openid.ns" => "http://specs.openid.net/auth/2.0",
              "openid.mode" => "checkid_setup",
              "openid.return_to" => "http://rogueconsumerapp.com/",
              "openid.identity" => @identity_url,
              "openid.claimed_id" => @identity_url
            }

            sso_login_as(@user)
            get "/sso", params
            last_response.status.should == 403
          end
        end
      end
        
      describe "when NOT authenticated" do
        it "should require authentication" do
          params = {
            "openid.ns" => "http://specs.openid.net/auth/2.0",
            "openid.mode" => "checkid_setup",
            "openid.return_to" => @consumer.url,
            "openid.identity" => @identity_url,
            "openid.claimed_id" => @identity_url
          }

          get "/sso", params
          last_response.body.should be_a_login_form
        end
      end      
    end

    describe "with openid mode of checkid_immediate" do
      describe "unauthenticated user" do
        it "should require authentication" do
          params = {
            "openid.ns" => "http://specs.openid.net/auth/2.0",
            "openid.mode" => "checkid_immediate",
            "openid.return_to" => @consumer.url,
            "openid.identity" => @identity_url,
            "openid.claimed_id" => @identity_url
          }

          get "/sso", params
          last_response.body.should be_a_login_form
        end
      end
      
      describe "authenticated user" do
        describe "with appropriate request parameters" do
          it "should redirect to the consumer app" do
            params = {
              "openid.ns" => "http://specs.openid.net/auth/2.0",
              "openid.mode" => "checkid_immediate",
              "openid.return_to" => @consumer.url,
              "openid.identity" => @identity_url,
              "openid.claimed_id" => @identity_url
            }

            sso_login_as(@user)
            get "/sso", params
            last_response.should be_an_openid_immediate_response(@consumer, @user)
          end
        end

        describe "attempting to access from an untrusted consumer" do
          it "cancel the openid request" do
            params = {
              "openid.ns" => "http://specs.openid.net/auth/2.0",
              "openid.mode" => "checkid_immediate",
              "openid.return_to" => "http://rogueconsumerapp.com/",
              "openid.identity" => @identity_url,
              "openid.claimed_id" => @identity_url
            }

            sso_login_as(@user)
            get "/sso", params
            last_response.status.should == 403
          end
        end
      end
    end
  end
  
  describe "Requesting the server's xrds" do
    describe "when accepting xrds+xml" do
      it "renders the provider idp page" do
        get '/sso/xrds'
        last_response.headers['Content-Type'].should eql('application/xrds+xml')
        last_response.should have_xpath("//xrd/service[uri='http://example.org/sso']")
        last_response.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/server']")
      end
    end
  end

  describe "Requesting a user's xrds" do
    before(:each) do
      User.delete_all
      @user = User.create!(Factory.attributes_for(:user))
    end

    it "renders the users idp page" do
      get "/sso/users/#{@user.id}"

      last_response.headers['Content-Type'].should eql('application/xrds+xml')
      last_response.headers['X-XRDS-Location'].should eql("http://example.org/sso/users/#{@user.id}")
      last_response.body.should have_xpath("//xrd/service[uri='http://example.org/sso']")
      last_response.body.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
    end
  end
  
end