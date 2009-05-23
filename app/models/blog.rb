class Blog < ActiveRecord::Base
  belongs_to :account
  
  acts_as_authorizable
  
  # Returns an array of contributors
  def contributors
    has_contributors
  end
  
end
