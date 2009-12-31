# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'sinatra/base'
require 'haml'
require 'openid'
require 'openid/store/filesystem'
require 'openid/extensions/sreg'

class HotinkSso < Sinatra::Base
 include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation
  
 helpers do
    def sign_in(user)
      if user.nil?
        session.delete(:checkpoint_user_id)
      else
        session[:checkpoint_user_id] = user.id
      end
    end
    
    def ensure_authenticated
     if trust_root = session_return_to || params['return_to']
       if SsoConsumer.allowed?(trust_root)
         if current_user
           redirect "#{trust_root}?id=#{current_user.id}"
         else
           session[:checkpoint_return_to] = trust_root
         end
       else
         forbidden!
       end
     end
     throw(:halt, [401, haml(:login_form)]) unless current_user
   end
   
    def forbidden!
      throw :halt, [403, 'Forbidden']
    end
   
    def current_user
      session[:checkpoint_user_id].nil? ? nil : User.find(session[:checkpoint_user_id])
    end
   
    def signed_in?
     !current_user.nil?
   end
   
    def session_return_to
     session[:checkpoint_return_to]
    end
   
    def absolute_url(suffix = nil)
      port_part = case request.scheme
                  when "http"
                    request.port == 80 ? "" : ":#{request.port}"
                  when "https"
                    request.port == 443 ? "" : ":#{request.port}"
                  end
        "#{request.scheme}://#{request.host}#{port_part}#{suffix}"
    end
    
    def server
      if @server.nil?
        store = OpenID::Store::Filesystem.new(File.join(Dir.tmpdir, 'openid-store'))
        @server = OpenID::Server::Server.new(store, absolute_url('/sso'))
      end
      return @server
    end
    
    def url_for_user
      absolute_url("/sso/users/#{current_user.nil? ? "no-user" : current_user.id}")
    end
    
    def render_response(oidresp)
      if oidresp.needs_signing
        signed_response = server.signatory.sign(oidresp)
      end
      web_response = server.encode_response(oidresp)

      case web_response.code
      when 302
        redirect web_response.headers['location']
      else
        web_response.body
      end
    end

  end
  
  enable :sessions
  enable :methodoverride
  set :views, File.dirname(__FILE__) + '/../views/sso'
  
  get '/sso/xrds' do
    response.headers['Content-Type'] = 'application/xrds+xml'
    @types = [ OpenID::OPENID_IDP_2_0_TYPE ]
    erb :yadis, :layout => false
  end

  get '/sso/users/:id' do
    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::SREG_URI ]
    response.headers['Content-Type'] = 'application/xrds+xml'
    response.headers['X-XRDS-Location'] = absolute_url("/sso/users/#{params['id']}")

    erb :yadis, :layout => false
  end
    
  [:get, :post].each do |meth|
      send(meth, '/sso') do
        begin
          oidreq = server.decode_request(params)
        rescue OpenID::Server::ProtocolError => e
          oidreq = session[:checkpoint_last_oidreq]
        end
        throw(:halt, [400, 'Bad Request']) unless oidreq
       
        oidresp = nil
      
        if oidreq.kind_of?(OpenID::Server::CheckIDRequest)
          # Store request
          session[:checkpoint_last_oidreq] = oidreq
          session[:checkpoint_return_to] = oidreq.return_to
        
          # Authenticate user AND consumer
          throw(:halt, [401, haml(:login_form)]) unless current_user
          unless oidreq.identity == url_for_user
             forbidden!
          end
          forbidden! unless SsoConsumer.allowed?(oidreq.trust_root)

          oidresp = oidreq.answer(true, nil, oidreq.identity)
        
          # Add in Sreg data
          sreg_data = {
            'email' => current_user.email
          }
          oidresp.add_extension(OpenID::SReg::Response.new(sreg_data))
        else
          oidresp = server.handle_request(oidreq)
        end
      
        render_response(oidresp)
      end
  end
      
  get '/sso/login' do
    ensure_authenticated
    redirect absolute_url("/")
  end
  
  post '/sso/login' do
    session = UserSession.new(:login => params['email'], :password => params['password'], :remember_me => false)
    if session.save
      sign_in(session.user)
    end
    ensure_authenticated
    redirect session_return_to || absolute_url("/")
  end
  
  get '/sso/logout' do
    current_session = UserSession.find
    current_session.destroy if current_session
    session.clear
    redirect absolute_url("/sso/login")
  end
      
end
