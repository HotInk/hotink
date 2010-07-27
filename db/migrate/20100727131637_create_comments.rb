class CreateComments < ActiveRecord::Migration
  def self.up
    create_table "comments" do |t|
      t.string    "name"
      t.string    "email"
      t.text      "body"
      t.string    "website"
      t.string    "ip_address"
      t.integer   "flags"
      
      t.integer   "account_id"
      t.integer   "document_id"
      
      t.timestamps
    end
    
    add_index("comments", "document_id")
  end

  def self.down
    drop_table "comments"
  end
end
