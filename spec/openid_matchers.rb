require 'addressable/uri'

module OpenidMatchers

  class ReturnAnOpenIDAssociateResponse
      include Spec::Matchers

      def initialize(session)
        @openid_session = session
      end

      def matches?(target)
        message = OpenID::Message.from_kvform("#{target.body}") # wtf do i have to interpolate this!
        secret = @openid_session.extract_secret(message)
        secret.should_not be_nil

        args = message.get_args(OpenID::OPENID_NS)

        args['assoc_type'].should == 'HMAC-SHA1'
        args['assoc_handle'].should =~ /^\{HMAC-SHA1\}\{[^\}]{8}\}\{[^\}]{8}\}$/
        args['session_type'].should == 'DH-SHA1'
        args['enc_mac_key'].size.should == 28
        args['expires_in'].should =~ /^\d+$/
        args['dh_server_public'].size.should == 172
        true
      end
      def failure_message
        puts "Expected an OpenID Associate Response"
      end
  end
  
  def be_an_openid_associate_response(openid_session)
    ReturnAnOpenIDAssociateResponse.new(openid_session)
  end
  
  class RedirectToConsumer
    include Spec::Matchers

    def initialize(consumer, user)
      @consumer, @user = consumer, user
      @identity_url = "http://example.org/sso/users/#{user.id}"
    end

    def matches?(target)
      target.status.should == 302

      redirect_params = Addressable::URI.parse(target.headers['Location']).query_values

      redirect_params['openid.ns'].should == 'http://specs.openid.net/auth/2.0'
      redirect_params['openid.mode'].should == 'id_res'
      redirect_params['openid.return_to'].should == @consumer.url
      redirect_params['openid.assoc_handle'].should =~ /^\{HMAC-SHA1\}\{[^\}]{8}\}\{[^\}]{8}\}$/
      redirect_params['openid.op_endpoint'].should == 'http://example.org/sso'
      redirect_params['openid.claimed_id'].should == @identity_url
      redirect_params['openid.identity'].should == @identity_url

      redirect_params['openid.sreg.email'].should == @user.email

      redirect_params['openid.sig'].should_not be_nil
      redirect_params['openid.signed'].should_not be_nil
      redirect_params['openid.response_nonce'].should_not be_nil
      true
    end
    def failure_message
      puts "Expected a redirect to the consumer"
    end
  end

  def be_a_redirect_to_the_consumer(consumer, user)
    RedirectToConsumer.new(consumer, user)
  end
  
  class LoginForm
    include ::Webrat::Matchers
    
    def matches?(target)
      target.should have_selector("form[action='/sso/login'][method='POST']")
      target.should have_selector("form[action='/sso/login'][method='POST'] input[type='text'][name='login']")
      target.should have_selector("form[action='/sso/login'][method='POST'] input[type='password'][name='password']")
      true
    end
    def failure_message
      puts "Expected a login form to be displayed, it wasn't"
    end
  end

  def be_a_login_form
    LoginForm.new
  end
  
  class ReturnAnOpenIDImmediateResponse
        include Spec::Matchers
        include Webrat::Matchers
        
        def initialize(consumer, user)
          @consumer, @user = consumer, user
          @identity_url = "http://example.org/sso/users/#{user.id}"
        end

        def matches?(target)
          target.status.should == 302

          redirect_params = Addressable::URI.parse(target.headers['Location']).query_values

          redirect_params['openid.ns'].should == 'http://specs.openid.net/auth/2.0'
          redirect_params['openid.mode'].should == 'id_res'
          redirect_params['openid.return_to'].should == @consumer.url
          redirect_params['openid.assoc_handle'].should =~ /^\{HMAC-SHA1\}\{[^\}]{8}\}\{[^\}]{8}\}$/
          redirect_params['openid.op_endpoint'].should == 'http://example.org/sso'
          redirect_params['openid.claimed_id'].should == @identity_url
          redirect_params['openid.identity'].should == @identity_url

          redirect_params['openid.sreg.email'].should == @user.email

          redirect_params['openid.sig'].should_not be_nil
          redirect_params['openid.signed'].should_not be_nil
          redirect_params['openid.response_nonce'].should_not be_nil
          true
        end
        def failure_message
          puts "Expected an OpenID Associate Response"
        end
      end
      def be_an_openid_immediate_response(consumer, user)
        ReturnAnOpenIDImmediateResponse.new(consumer, user)
      end

end
