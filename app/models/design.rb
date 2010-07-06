class Design < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
    
  validates_presence_of :name 
  
  has_many :templates, :dependent => :destroy
  has_many :view_templates
  has_many :layouts
  has_many :partial_templates
  
  has_many :template_files
  has_many :stylesheets
  has_many :javascript_files
  
  has_one :article_template
  has_one :page_template
  has_one :search_results_template
  has_one :blog_template
  has_one :blog_index_template
  has_one :entry_template

  has_many :front_page_templates
  belongs_to :current_front_page_template, :class_name => "FrontPageTemplate", :foreign_key => :current_front_page_template_id
  
  def current_design?
    self==account.current_design
  end
  
  def create_view_templates
    self.create_article_template
    self.create_blog_template
    self.create_blog_index_template
    self.create_entry_template
    self.create_page_template
    self.create_search_results_template
    
    self.front_page_templates.create(:name => 'Default front page')
  end
  
  after_create :create_view_templates
  
end

class Template < ActiveRecord::Base
  belongs_to :design
  validates_presence_of :design
  
  # A before filter to parse the Liquid template stored in self.code
   def parse_code
     write_attribute(:parsed_code, Marshal::dump(Liquid::Template.parse(self.code)))
   end
   before_save :parse_code
   
  # Render parsed Liquid template code
  def render(options=nil, registers = nil)
    parsed_code = Marshal::load(read_attribute(:parsed_code))
    parsed_code.render(options, registers)
  end
  
  after_save :touch_design
  
  private
  
  def touch_design
    design.touch
  end

end

class Layout < Template
  validates_presence_of :name
  validates_format_of :code, :with => /\{\{\s*page_contents\s*\}\}/, :message => "must contain 'page_contents', to load the rendered template's contents"

  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
       "This template contains a shared top and bottom for other templates. Be sure to include the 'page_contents' variable somewhere inside."
    else
      stored_description
    end
  end
end

class PartialTemplate < Template
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
       "This template can be included inside other templates using the 'include' tag."
    else
      stored_description
    end
  end
end

class ViewTemplate < Template
  belongs_to :layout
  
  def parse_code
    write_attribute(:parsed_code, Marshal::dump(Liquid::Template.parse(self.code)))
    write_attribute(:parsed_title_code, Marshal::dump(Liquid::Template.parse(self.title_code)))
  end
  
  def render(options={}, registers={})
    rendered_title = Marshal::load(parsed_title_code).render(options, registers)
    if layout
      layout.render(options.merge({'page_title' => rendered_title, 'page_contents' => super(options.merge('page_title' => rendered_title), registers)}), registers)
    else
      super(options.merge('page_title' => rendered_title), registers)
    end
  end
end


# View templates

class FrontPageTemplate < ViewTemplate
  DEFAULT_DESCRIPTION = "Renders a front page."
  
  validates_presence_of :name
  
  def name
    read_attribute :name
  end
end

class ArticleTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
      "Renders each article pages."
    else
      stored_description
    end
  end
end

class BlogTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
      "Renders a blog's main page."
    else
      stored_description
    end
  end
end

class BlogIndexTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
      "Renders the list of blogs."
    else
      stored_description
    end
  end
end

class EntryTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
       "Renders each blog entry page."
    else
      stored_description
    end
  end
end

class PageTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
       "Renders your static pages."
    else
      stored_description
    end
  end
end

class SearchResultsTemplate < ViewTemplate
  def description
    stored_description = read_attribute(:description)
    if stored_description.blank?
       "Renders the results of a search."
    else
      stored_description
    end
  end
end


class TemplateFile < ActiveRecord::Base
  belongs_to :design
  validates_presence_of :design
  
  has_attached_file :file, :path => ":rails_root/public/system/designs/:design/media/:basename.:extension", :url => "/system/designs/:design/media/:basename.:extension"
  validates_attachment_presence :file

  def url
    self.file.url
  end
  
  def file_name
    file_file_name
  end
  
  def file_size
    file_file_size
  end
  
  after_save :touch_design
  
  private
  
  def touch_design
    design.touch
  end
end

class JavascriptFile < TemplateFile
  has_attached_file :file, :path => ":rails_root/public/system/designs/:design/javascripts/:basename.:extension", :url => "/system/designs/:design/javascripts/:basename.:extension"
end

class Stylesheet < TemplateFile
  has_attached_file :file, :path => ":rails_root/public/system/designs/:design/stylesheets/:basename.:extension", :url => "/system/designs/:design/stylesheets/:basename.:extension"
end

