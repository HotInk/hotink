class Printing < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :issue
  belongs_to :document
  belongs_to :articles, :source => :document, :conditions => { :type => "Article" }
end
