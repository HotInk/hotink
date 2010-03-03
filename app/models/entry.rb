class Entry < Document
  has_many :blogs, :through => :postings
  
  has_many :postings
end
