require 'spec_helper'

describe Waxing do
  it { should belong_to(:account) }
  
  it { should belong_to(:mediafile) }
  it { should validate_presence_of(:mediafile) }
  
  it { should belong_to(:document) }
  it { should validate_presence_of(:document) }
  it { should belong_to(:article) }
end
