class Waxing < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :attachments
  belongs_to :articles 
end
