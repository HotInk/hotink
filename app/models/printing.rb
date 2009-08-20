class Printing < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :issue
  belongs_to :document
  belongs_to :article, :foreign_key => :document_id
end
