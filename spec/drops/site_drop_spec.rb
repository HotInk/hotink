require 'spec_helper'

describe SiteDrop do
  describe "site url" do
    before do
      @account = Factory(:account)
    end
    
    it "should return site url if supplied" do
      @account.site_url = "http://yoursite.com"
      output = Liquid::Template.parse( '  {{ site.url }}  '  ).render('site' => SiteDrop.new(@account))
      output.should == "  http://yoursite.com  "
    end
    
    it "should return a default site url if none supplied" do
      output = Liquid::Template.parse( '  {{ site.url }}  '  ).render('site' => SiteDrop.new(@account))
      output.should == "  /accounts/#{@account.id}  "
    end
  end

end