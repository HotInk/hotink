class AddSectionIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :section_id, :integer
  end

  def self.down
    remove_column :articles, :section_id
  end
end
