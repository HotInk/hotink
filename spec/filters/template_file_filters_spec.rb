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
  
  describe "template file tag" do
    context "with a javascript file" do
      before do
        @template_file = Factory(:javascript_file, :design => @design)
      end
    
      it "should return an external script tag" do
        output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
        output.should == " <script src=\"#{@template_file.url}\" type=\"text/javascript\" charset=\"utf-8\"></script> "
      end
    end
    
    context "with an image" do
      context "with a jpeg" do
        before do
          @template_file = Factory(:template_file, :file => File.new(RAILS_ROOT + "/spec/fixtures/test-jpg.jpg"), :design => @design)
        end
    
        it "should return an image tag" do
          output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
          output.should == " <img src=\"#{@template_file.url}\" /> "
        end
      end
      
      context "with a gif" do
        before do
          @template_file = Factory(:template_file, :file => File.new(RAILS_ROOT + "/spec/fixtures/test-gif.gif"), :design => @design)
        end
    
        it "should return an image tag" do
          output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
          output.should == " <img src=\"#{@template_file.url}\" /> "
        end
      end
      
      context "with a png" do
        before do
          @template_file = Factory(:template_file, :file => File.new(RAILS_ROOT + "/spec/fixtures/test-png.png"), :design => @design)
        end
    
        it "should return an image tag" do
          output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
          output.should == " <img src=\"#{@template_file.url}\" /> "
        end
      end
    end
    
    context "with a stylesheet" do
      before do
        @template_file = Factory(:stylesheet, :design => @design)
      end
    
      it "should return an image tag" do
        output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
        output.should == " <link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"#{@template_file.url}\" /> "
      end
    end
    
    context "with a general file" do
      before do
        @template_file = Factory(:template_file, :file => File.new(RAILS_ROOT + "/spec/fixtures/test-txt.txt"), :design => @design)
      end
    
      it "should return a link" do
        output = Liquid::Template.parse( " {{ \"#{@template_file.file_file_name}\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
        output.should == " <a href=\"#{@template_file.url}\" name=\"#{@template_file.file_file_name}\">#{@template_file.file_file_name}</a> "
      end
    end 
    
    context "with bad file name" do    
      it "should return an image tag" do
        output = Liquid::Template.parse( " {{ \"no-file-with-this-name.txt\" | template_file_tag }} "  ).render({}, :filters => [TemplateFileFilters], :registers => { :design => @design } )
        output.should == " <!-- No template file named:\"no-file-with-this-name.txt\" --> "
      end
    end   
  end
  
end
