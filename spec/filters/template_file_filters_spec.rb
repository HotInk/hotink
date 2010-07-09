require 'spec_helper'

describe TemplateFileFilters do
  before do
    @design = Factory(:design)
    @template_file = Factory(:template_file, :design => @design)
  end

  describe "template file url" do
    it "should return url of template file" do
      output = Liquid::Template.parse( " {{ '#{@template_file.file_name}' | template_file_url }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design})
      output.should == " #{@template_file.url} "
    end
    
    it "should output error for non-existant template file" do
      output = Liquid::Template.parse( " {{ 'no file' | template_file_url }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design})
      output.should == " <!-- This design has no template file named \"no file\" --> "
    end
    
    it "should only return template files from the design being used" do
      other_design = Factory(:design)
      other_design_template_file = Factory(:template_file, :file => File.new(RAILS_ROOT + '/spec/fixtures/test_js.js'), :design => other_design)
      template = Liquid::Template.parse( " {{ '#{other_design_template_file.file_name}' | template_file_url }} "  )
      
      output = template.render({}, :filters => [TemplateFileFilters], :registers => { :design => @design})
      output.should == " <!-- This design has no template file named \"#{other_design_template_file.file_name}\" --> "
    end
  end
  
  
end
