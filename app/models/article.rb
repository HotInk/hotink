class Article < Document
  include Pacecar
  has_one :checkout, :foreign_key => :duplicate_article_id, :dependent => :destroy
  has_one :pickup, :class_name => "Checkout", :foreign_key => :original_article_id
  
  # A photocopy is an account neutral version of an article, used to transfer between accounts
  def photocopy
    copy = clone
    
    # Copy over associations
    authors.each { |a| copy.authors << a }

    # Remove account-specific attributes
    copy.account = nil
    copy.section = nil
    copy.status = nil
    
    copy
  end
  
  def to_liquid
    {'title' => title, 'subtitle' => subtitle, 'authors_list' => authors_list, 'bodytext' => bodytext}
  end
end
