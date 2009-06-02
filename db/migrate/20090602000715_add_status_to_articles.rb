class AddStatusToArticles < ActiveRecord::Migration
  def self.up
    add_column :documents, :status, :string
    rename_column :documents, :date, :published_at
  end

  def self.down
    remove_column :documents, :status
    rename_column :documents, :published_at, :date
  end
end
