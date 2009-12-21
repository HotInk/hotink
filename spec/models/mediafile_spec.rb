require 'spec_helper'

describe Mediafile do

  before(:each) do
    @mediafile = Article.create!(Factory.attributes_for(:mediafile))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }

  it "should create a human readable list of authors' names" do
    @mediafile.authors = [Factory(:author, :name => "Lilly")]
    @mediafile.authors_list.should == "Lilly"
    
    @mediafile.authors << Factory(:author, :name => "Marshall")
    @mediafile.authors_list.should == "Lilly and Marshall"
    
    @mediafile.authors << Factory(:author, :name => "Robin")
    @mediafile.authors_list.should == "Lilly, Marshall and Robin"
    
    @mediafile.authors << Factory(:author, :name => "Barney")
    @mediafile.authors_list.should == "Lilly, Marshall, Robin and Barney"
  end

  it "should break up a comma (with 'and') seperated string of authors' names to create authors array" do
    @mediafile.authors_list = "Lilly, Marshall and Robin"
    @mediafile.authors.length.should == 3
  end
  
  it "should create account-neutral photocopies of itself" do
    original = Factory(:detailed_mediafile)
    new_account = Factory(:account)
    photocopy = original.photocopy(new_account)
    
    photocopy.should_not be_new_record
    photocopy.account.should == new_account
    photocopy.authors_list.should == original.authors_list

    photocopy.file.should_not be_nil
    photocopy.file_content_type.should == original.file_content_type
    photocopy.file_file_size.should == original.file_file_size
  end

end