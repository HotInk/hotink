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

ActiveRecord::Schema.define(:version => 20090613190056) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "formal_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
    t.text     "settings"
  end

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorships", :force => true do |t|
    t.string   "staff_position"
    t.integer  "document_id"
    t.integer  "author_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "description"
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
    t.integer  "position"
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.string   "alternate_title"
    t.string   "subtitle"
    t.text     "bodytext"
    t.string   "summary"
    t.datetime "published_at"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "section_id"
    t.boolean  "delta"
    t.string   "type"
    t.string   "status"
  end

  create_table "issues", :force => true do |t|
    t.date     "date"
    t.integer  "number"
    t.integer  "volume"
    t.string   "description"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pdf_file_name"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string   "name"
  end

  create_table "mediafiles", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link_alternate"
    t.date     "date"
    t.integer  "account_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 50
    t.string   "secret",                :limit => 50
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "photocredits", :force => true do |t|
    t.integer  "mediafile_id"
    t.integer  "author_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postings", :force => true do |t|
    t.integer  "account_id"
    t.integer  "entry_id"
    t.integer  "blog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printings", :force => true do |t|
    t.integer  "document_id"
    t.integer  "issue_id"
    t.string   "page_number"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sortings", :force => true do |t|
    t.integer  "category_id"
    t.integer  "document_id"
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

  create_table "users", :force => true do |t|
    t.string   "login",               :default => "", :null => false
    t.string   "email",               :default => "", :null => false
    t.string   "crypted_password",    :default => "", :null => false
    t.string   "password_salt",       :default => "", :null => false
    t.string   "persistence_token",   :default => "", :null => false
    t.string   "single_access_token", :default => "", :null => false
    t.string   "perishable_token",    :default => "", :null => false
    t.integer  "login_count",         :default => 0,  :null => false
    t.integer  "failed_login_count",  :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "preferences"
  end

  create_table "waxings", :force => true do |t|
    t.integer  "mediafile_id"
    t.integer  "document_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "caption"
  end

end
