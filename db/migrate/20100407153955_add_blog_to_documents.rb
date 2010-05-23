class AddBlogToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :blog_id, :integer
  end

  def self.down
    remove_column :documents, :blog_id
  end
end
