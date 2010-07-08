class CreateListsAndListItems < ActiveRecord::Migration
  def self.up
    create_table "list_items" do |t|
      t.integer "list_id"
      t.integer "position"
      t.integer "document_id"
    end

    add_index "list_items", ["document_id"], :name => "index_list_items_on_document_id"
    add_index "list_items", ["list_id"], :name => "index_list_items_on_list_id"

    create_table "lists" do |t|
      t.integer  "account_id"
      t.string   "name"
      t.string   "slug"
      t.text     "description"
      t.integer  "owner_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "lists"
    drop_table "list_items"
  end
end
