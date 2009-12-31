ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'webrat'
require 'spec'
require 'spec/autorun'
require 'spec/rails'
require 'rack/test'
require 'shoulda'
require 'openid_matchers'
 
def sso_login_as(user)
   post '/sso/login', :login => user.login, :password => user.password
end
 
Spec::Runner.configure do |config|
  config.include(OpenidMatchers)
  
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end