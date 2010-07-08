require 'spec_helper'

describe ListItem do
  it { should belong_to(:list) }
  it { should validate_presence_of(:list) }
  it { should have_db_index(:list_id)}
  
  it { should belong_to(:document) }
  it { should validate_presence_of(:document) }
  it { should have_db_index(:document_id) }
end
