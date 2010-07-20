class AddDesignEngine < ActiveRecord::Migration
  def self.up
    create_table "designs" do |t|
      t.integer  "account_id"
      t.string   "name"
      t.text     "description"
      t.integer  "default_layout_id"
      t.integer  "current_front_page_template_id"
      
      t.timestamps
    end 
    
    create_table "template_files", :force => true do |t|
      t.integer  "design_id"
      t.string   "type"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.datetime "file_updated_at"
      
      t.timestamps
    end

    create_table "templates", :force => true do |t|
      t.integer  "design_id"
      t.string   "name"
      t.text     "description"
      t.text     "code"
      t.binary   "parsed_code"
      t.integer  "layout_id"
      t.string   "type"
      t.text     "title_code"
      t.binary   "parsed_title_code"
      
      t.timestamps
    end
    
    add_column "accounts", "current_design_id", "integer"
  end

  def self.down
    drop_table "designs"
    drop_table "template_files"
    drop_table "templates"
    
    remove_column 'accounts', "current_design_id"
  end
end
