class Article < Document
  include Pacecar
  has_one :checkout, :foreign_key => :duplicate_article_id, :dependent => :destroy
  has_one :pickup, :class_name => "Checkout", :foreign_key => :original_article_id
  
  named_scope :and_related_items, :include => [:authors, :mediafiles, :section]
  
  named_scope :drafts, :conditions => "status is null AND created_at != updated_at"
  named_scope :scheduled, lambda { {:conditions => ["status = 'Published' AND published_at > ?", Time.now.utc]} }
  named_scope :published, lambda { {:conditions => ["status = 'Published' AND published_at <= ?", Time.now.utc]} }
  
  def published?
    (self.status=='Published') && (self.published_at <= Time.now)
  end
  
  def draft?
    self.status.nil? && (self.updated_at != self.created_at)
  end
  
  def scheduled?
    (self.status=='Published') && (self.published_at > Time.now)
  end
  
  def untouched?
     self.status.nil? && (self.updated_at == self.created_at)
  end
  
  # A photocopy is an account neutral version of an article, used to transfer between accounts
  def photocopy(new_account)
    copy = clone
    
    # Remove account-specific attributes
    copy.account = new_account
    copy.section = nil
    copy.status = nil
    
    copy.save
    
    # has_many :through assocaitions can't be applied until the new record has been saved
    authors.each { |a| copy.authors << a }
    mediafiles.each do |m| 
      mediafile = m.photocopy(new_account)
      copy.mediafiles << mediafile 
    end
    
    copy.new_record? ? false : copy
  end
  
  def word_count
    bodytext.scan(/\w+/).size
  end
  
  def to_liquid
    {'title' => title, 'subtitle' => subtitle, 'authors_list' => authors_list, 'bodytext' => bodytext, 'id' => id.to_s}
  end
end
