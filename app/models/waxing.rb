class Waxing < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :mediafile
  
  belongs_to :document
  belongs_to :article
end
