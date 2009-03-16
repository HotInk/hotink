# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures

require 'webrat'
require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

require 'factory_girl' 
require 'test/factories'


Webrat.configure do |config|
  config.mode = :rails
end

