class AddSlugToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :slug, :string
    add_index :blogs, :slug
  end

  def self.down
    remove_column :blogs, :slug
  end
end
