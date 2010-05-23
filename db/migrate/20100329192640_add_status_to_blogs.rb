class AddStatusToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :status, :boolean, :default => false
  end

  def self.down
    remove_column :blogs, :status
  end
end
