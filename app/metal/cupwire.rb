# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Cupwire < ArticleStream::App
  set :owner_account_id, 24
end
