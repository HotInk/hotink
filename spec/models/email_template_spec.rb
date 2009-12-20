require 'spec_helper'

describe EmailTemplate do
  before(:each) do
    @email_template = EmailTemplate.create!(Factory.attributes_for(:email_template))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:name) }
  
  it "should render its liquid template attributes" do
    account = Factory(:account)
    articles = (1..3).collect { Factory(:article, :account => account) }
    email_template = Factory(:email_template_with_articles, :account => account)
    
    email_template.render_html('account' => account, 'articles' => articles).should == Liquid::Template.parse(email_template.html).render('account' => account, 'articles' => articles)
    email_template.render_plaintext('account' => account, 'articles' => articles).should == Liquid::Template.parse(email_template.plaintext).render('account' => account, 'articles' => articles)
  end
end
