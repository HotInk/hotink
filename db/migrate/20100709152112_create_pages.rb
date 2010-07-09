class CreatePages < ActiveRecord::Migration
  def self.up
    create_table "pages" do |t|
      t.string   "name"
      t.text     "contents"
      t.integer  "template_id"
      t.integer  "parent_id"
      t.integer  "account_id"
     
      t.timestamps
    end
  end

  def self.down
    drop_table "pages"
  end
end
