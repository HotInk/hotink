ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'webrat'
require 'spec'
require 'spec/autorun'
require 'spec/rails'
require 'rack/test'
require 'shoulda'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end
