require 'rubygems'
require 'spork'
ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  
  require 'webrat'
  require 'rack/test'
  require 'shoulda'
  require 'spec'
  require 'spec/autorun'
  require 'spec/rails'
  require File.expand_path(File.join(File.dirname(__FILE__),'openid_matchers'))
  require "paperclip/matchers"
  
  require 'settings'
  
  Spec::Runner.configure do |config|
    config.include OpenidMatchers
    config.include Paperclip::Shoulda::Matchers

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
  end
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end


def sso_login_as(user)
   post '/sso/login', :login => user.login, :password => user.password
end
 
