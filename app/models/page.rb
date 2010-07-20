class Page < ActiveRecord::Base
  
  belongs_to :account
  validates_presence_of :account
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[-a-zA-Z0-9\_]+$/
  
  belongs_to :parent, :class_name => "Page", :foreign_key => "parent_id" 
  named_scope :main_pages, :conditions => { :parent_id => nil }
  has_many :child_pages, :class_name => "Page", :foreign_key => "parent_id", :order => :name

  # Find page using a path of parent-child page names (ie. "page-1/page2") or an array of page names (ie ["page1", "page2"])
  def self.find_by_path(path)
    if path.is_a? Array
      page_names = path
    elsif path.is_a? String
      page_names = path.split("/")
    end
    page = self.main_pages.find_by_name(page_names.delete_at(0))
    raise ActiveRecord::RecordNotFound unless page
    unless page_names.blank?
      page_names.each do |page_name|
        page = page.child_pages.find_by_name(page_name)
        raise ActiveRecord::RecordNotFound unless page
      end
    end
    page
  end
  
  def url
    "#{parent_url}/#{name.downcase}"
  end
  
  def parent_url
    if parent
      parent.url
    else
      ""
    end
  end
  
  belongs_to :template, :class_name => "PageTemplate", :foreign_key => "template_id"
  
  def to_html(user = nil)
    if template
      template.render({'current_user' => user, 'contents' => RDiscount.new(contents).to_html})
    else  
      RDiscount.new(contents).to_html
    end
  end
end
