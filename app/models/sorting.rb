class Sorting < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :category
  belongs_to :section, :foreign_key => :category_id, :class_name => "Section"
  belongs_to :article
end
