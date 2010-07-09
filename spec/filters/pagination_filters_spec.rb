require 'spec_helper'

describe PaginationFilters do
  before do
    @design = Factory(:design)
  end

  describe "next page link" do
    context "when viewing current design" do
      before do
        @design.make_current
      end
      
      context "without enough total entires to paginate" do
        before do
          @context = { :design => @design  }
        end
        
        it "should not render next page link unless context indicates there are enough entries" do
          link_text = "Next"
          output = Liquid::Template.parse( " {{ \"#{link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == "  "
        end
      end
      
      context "with more than enough total entries to paginate" do
        before do
          @context = { :design => @design, :total_entries => 21  }
          @link_text = "Next"
        end
        
        it "should render next page if context indicates there are enough entries" do
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=2\">#{@link_text}</a> "
        end
        
        it "should not render next page link when requesting page 2 if there aren't enough for page 3" do
          @context.merge!(:page => 2)
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == "  "
        end
        
        it "should render next page link when requesting page 2 if appropriate" do
          @context.merge!(:per_page => 10, :page => 2)
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=3&per_page=10\">#{@link_text}</a> "
        end
      end
      
      context "when the user requests fewer entries per page" do
        before do
          @context = { :design => @design, :per_page => 5, :total_entries => 7  }
          @link_text = "Next"
        end
        
        it "should render next page if context indicates there are enough entries" do
          link_text = "Next"
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=2&per_page=5\">#{@link_text}</a> "
        end
        
        it "should not render next page link when requesting page 2 if there aren't enough for page 3" do
          @context.merge!(:page => 2)
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == "  "
        end
        
        it "should render next page link when requesting page 2 if appropriate" do
          @context.merge!(:per_page => 3, :page => 2)
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | next_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=3&per_page=3\">#{@link_text}</a> "
        end
      end
    end
    
    context "when previewing a design other than the current one" do
      it "should insert design id into query string when building links" do
        link_text = "Next"
        output = Liquid::Template.parse( " {{ \"#{link_text}\"  | next_page_link }} "  ).render({}, :registers => { :design => @design, :total_entries => 21 })
        output.should == " <a href=\"?page=2&design_id=#{@design.id}\">#{link_text}</a> "
      end
    end
  end

  describe "previous page link" do
    context "when viewing current design" do
   	  before do
        @design.make_current
     	end

   	  context "with enough entries to paginate" do
     	  before do
     	    @context = { :design => @design, :total_entries => 21 }
     	    @link_text = "Previous"
     	  end

     	   context "when on first page" do
     	     it "should not render previous page link" do
     	       output = Liquid::Template.parse( " {{ \"#{@link_text}\" | previous_page_link }} "  ).render({}, :registers => @context)
     	       output.should == "  "
     	     end
     	   end

     	   context "when on page 2" do
     	     before do
     	       @context.merge!(:page => 2)
     	     end

     	     it "should render previous page link" do
     	       output = Liquid::Template.parse( " {{ \"#{@link_text}\" | previous_page_link }} "  ).render({}, :registers => @context)
     	       output.should == " <a href=\"?page=1\">#{@link_text}</a> "
     	     end
     	   end
     	end
     	
     	context "when the user requests fewer entries per page" do
        before do
          @context = { :design => @design, :page => 2, :per_page => 5, :total_entries => 7  }
          @link_text = "Previous"
        end
        
        it "should render previous page if context indicates there is a previous page" do
          link_text = "Next"
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | previous_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=1&per_page=5\">#{@link_text}</a> "
        end
        
        it "should render previous page link when requesting page w if appropriate" do
          @context.merge!(:per_page => 3, :page => 3)
          output = Liquid::Template.parse( " {{ \"#{@link_text}\" | previous_page_link }} "  ).render({}, :registers => @context)
          output.should == " <a href=\"?page=2&per_page=3\">#{@link_text}</a> "
        end
      end
    end
    
    context "when previewing a design other than the current one" do
      it "should insert design id into query string when building links" do
        link_text = "Previous"
        output = Liquid::Template.parse( " {{ \"#{link_text}\"  | previous_page_link }} "  ).render({}, :registers => { :design => @design, :page => 2, :total_entries => 21 })
        output.should == " <a href=\"?page=1&design_id=#{@design.id}\">#{link_text}</a> "
      end
    end
  end

end

