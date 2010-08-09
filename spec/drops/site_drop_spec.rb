require 'spec_helper'

describe SiteDrop do
  before do
    @account = Factory(:account)
    @design = Factory(:design, :account => @account)
  end
  
  describe "urls" do
    before do
      @account.update_attribute :site_url, "http://test.hotink.net"
    end

    context "when viewing current design" do
      before do
        @design.make_current
      end
      
      it "should return front page url" do
        output = Liquid::Template.parse( '  {{ site.front_page_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/  "
      end
    
      it "should return blogs url" do
        output = Liquid::Template.parse( '  {{ site.blogs_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/blogs  "
      end
      
      it "should return issues url" do
        output = Liquid::Template.parse( '  {{ site.issues_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/issues  "
      end
      
      it "should return search url" do
        output = Liquid::Template.parse( '  {{ site.search_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/search  "
      end
    end
    
    context "when viewing alternate design" do
      it "should return front page url" do
        output = Liquid::Template.parse( '  {{ site.front_page_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/?design_id=#{@design.id}  "
      end
    
      it "should return blogs url" do
        output = Liquid::Template.parse( '  {{ site.blogs_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/blogs?design_id=#{@design.id}  "
      end
      
      it "should return issues url" do
        output = Liquid::Template.parse( '  {{ site.issues_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/issues?design_id=#{@design.id}  "
      end
      
      it "should return search url" do
        output = Liquid::Template.parse( '  {{ site.search_url }}  '  ).render({'site' => SiteDrop.new(@account)}, :registers => { :design => @design })
        output.should == "  #{@account.site_url}/search?design_id=#{@design.id}  "
      end
    end
  end
end