# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090225021340) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "formal_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
  end

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "alternate_title"
    t.string   "subtitle"
    t.text     "bodytext"
    t.string   "summary"
    t.datetime "date"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "section_id"
  end

  create_table "attachments", :force => true do |t|
    t.string   "filename"
    t.string   "file_type"
    t.integer  "filesize"
    t.string   "title"
    t.text     "description"
    t.integer  "width"
    t.integer  "height"
    t.string   "length"
    t.string   "link_alternate"
    t.date     "date"
    t.integer  "account_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorships", :force => true do |t|
    t.string   "staff_position"
    t.integer  "article_id"
    t.integer  "author_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "account_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", :force => true do |t|
    t.date     "date"
    t.integer  "number"
    t.integer  "volume"
    t.string   "description"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photocredits", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "author_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printings", :force => true do |t|
    t.integer  "article_id"
    t.integer  "issue_id"
    t.string   "page_number"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sortings", :force => true do |t|
    t.integer  "category_id"
    t.integer  "article_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "waxings", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "article_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
