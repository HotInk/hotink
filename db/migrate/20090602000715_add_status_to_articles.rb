class AddStatusToArticles < ActiveRecord::Migration
  def self.up
    add_column :documents, :status, :string
  end

  def self.down
    remove_column :documents, :status
  end
end
