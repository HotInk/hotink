require 'spec_helper'

describe SignOff do
  
  subject { SignOff.create!( :article_id => 1, :user_id => 1 ) } 

  it { should belong_to(:user) }
  it { should belong_to(:article) }

end
