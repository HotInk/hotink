require 'spec_helper'

describe Design do

  it { should belong_to(:account) }
  it { should validate_presence_of(:name) }
  
  it { should validate_presence_of(:name) }
  
  it { should have_many(:templates).dependent(:destroy) }
  it { should have_many(:view_templates) }
  it { should have_many(:layouts) }
  it { should have_many(:partial_templates) }

  it { should have_many(:template_files) }
  it { should have_many(:stylesheets) }
  it { should have_many(:javascript_files) }
  
  it { should have_one(:article_template) }
  it { should have_one(:page_template) }  
  it { should have_one(:category_template) }
  it { should have_one(:search_results_template) }
  it { should have_one(:issue_index_template) }
  it { should have_one(:issue_template) }
  it { should have_one(:blog_index_template) }
  it { should have_one(:blog_template) }
  it { should have_one(:entry_template) }
  it { should have_one(:not_found_template) }

  it { should have_many(:front_page_templates) }
  it { should belong_to(:current_front_page_template) }
  
  it "should create view templates on create" do
    design =  Factory(:design)
    design.article_template.should be_kind_of(ArticleTemplate)
    design.page_template.should be_kind_of(PageTemplate)
    design.category_template.should be_kind_of(CategoryTemplate)
    design.search_results_template.should be_kind_of(SearchResultsTemplate)
    design.issue_index_template.should be_kind_of(IssueIndexTemplate)
    design.issue_template.should be_kind_of(IssueTemplate)
    design.blog_index_template.should be_kind_of(BlogIndexTemplate)
    design.blog_template.should be_kind_of(BlogTemplate)
    design.entry_template.should be_kind_of(EntryTemplate)
    design.not_found_template.should be_kind_of(NotFoundTemplate)
  end
  
  it "should create one front page template to get things started" do
    design =  Factory(:design)
    design.front_page_templates.first.should be_kind_of(FrontPageTemplate)
    design.front_page_templates.first.name.should eql('Default front page')
  end
  
  it "should know if it is the current design" do
    design = Factory(:design)
    design.should_not be_current_design
    
    design.account.current_design = design
    design.should be_current_design
  end
  
  it "should be able to make itself the current design" do
    design = Factory(:design)
    design.should_not be_current_design
    
    design.make_current
    design.account.current_design.should eql(design)
  end
end

describe FrontPageTemplate do
  it { should validate_presence_of(:name) }
end

describe PartialTemplate do
  it { should validate_presence_of(:name) }
end

describe Layout do  
  it "should ensure code include page contents" do
    layout = Factory(:layout)
    layout.should allow_value("{{ page_contents }}").for(:code)
    layout.should allow_value("{{ page_contents }}").for(:code)
    layout.should allow_value("{{ page_contents }}").for(:code)
    
    layout.should_not allow_value("<h1>No contents</h1>").for(:code)    
  end
end

describe TemplateFile do
  before do
    @template_file = Factory(:template_file)
  end
  
  it { should belong_to(:design) }
  it { should validate_presence_of(:design) }
  
  it "should validate attached file" do
    TemplateFile.should have_attached_file(:file)
    TemplateFile.should validate_attachment_presence(:file)
  end
  
  describe "file attributes" do
    it "should know its file's url" do
      @template_file.url.should == @template_file.file.url
    end
    
    it "should know its file's name" do
      @template_file.file_name.should == @template_file.file_file_name
    end
    
    it "should know its file's size" do
      @template_file.file_size.should == @template_file.file_file_size
    end
  end
  
  it "should mark design as updated if template is updated" do
    Timecop.freeze Time.now
    design = Factory(:design, :updated_at => 1.day.ago)
    template_file = Factory(:template_file, :design => design)
    design.updated_at.should == Time.now
  end
end

describe ViewTemplate do
  
  it { should belong_to(:layout) }
  
  it "should render with the appropriate layout" do
    template = Factory(:view_template)
    template.render.should == Marshal.load(template.parsed_code).render
    
    template_layout = Factory(:layout)
    template.layout = template_layout
    template.render.should == template_layout.render({ 'page_contents' => Marshal.load(template.parsed_code).render })
  end
  
  it "should render title code and make it available in template" do
     template = Factory(:view_template, :title_code => 'view template title', :code => " {{ page_title }} ")

     template.render.should == " view template title "
  end
  
  it "should render title code and make it available in layout" do
    template = Factory(:view_template, :title_code => 'view template title')
    template.layout = Factory(:layout, :code => "{{ page_title }} {{ page_contents}}")
    
    template.render.should == template.layout.render({ 'page_title' => Marshal.load(template.parsed_title_code).render, 'page_contents' => Marshal.load(template.parsed_code).render })
  end
  
end

describe Template do
  it { should belong_to(:design) }
  it { should validate_presence_of(:design) }

  it "should render itself with appropriate options" do
    template = Factory(:template, :code => "Template #1 {{ contents }}")
    options = { 'contents' => "Testing my patience" }
    template.render(options).should == Liquid::Template.parse(template.code).render(options)
  end 

  it "should parse template code before each save" do
    template = Factory(:template)
    template.render.should == Liquid::Template.parse(template.code).render
    
    template.code = "Yo yo, it's yo template"
    template.save
    template.render.should == Liquid::Template.parse(template.code).render
  end
  
  it "should not save when saved with malformed template code" do
    template = Factory.attributes_for(:template)  
    template[:code] = "Hello {% "
    lambda{ Template.create(template) }.should raise_error(Liquid::SyntaxError)
  end
  
  it "should mark design as updated if template is updated" do
    Timecop.freeze Time.now
    design = Factory(:design, :updated_at => 1.day.ago)
    template = Factory(:template, :design => design)
    design.updated_at.should == Time.now
  end
end