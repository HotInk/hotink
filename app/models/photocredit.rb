class Photocredit < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :author
  belongs_to :attachment
end
