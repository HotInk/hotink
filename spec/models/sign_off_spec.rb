require 'spec_helper'

describe SignOff do
  
  subject { SignOff.create!( :article_id => 1, :user_id => 1, :published => false ) } 

  it { should belong_to(:user) }
  it { should belong_to(:article) }

end
