class AddDeltaToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :delta, :boolean
  end

  def self.down
    remove_column :articles, :delta
  end
end
