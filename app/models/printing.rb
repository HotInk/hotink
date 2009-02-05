class Printing < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :issue
  belongs_to :article
end
