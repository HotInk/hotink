class Membership < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  
  belongs_to :network_owner, :class_name => "Account", :foreign_key => :network_owner_id
  validates_presence_of :network_owner
end
