class AddStatusToArticles < ActiveRecord::Migration
  def self.up
    remove_column :documents, :date
    add_column :documents, :status, :string
    add_column :documents, :published_at, :datetime
  end

  def self.down
    remove_column :documents, :status
    remove_column :documents, :published_at
    add_column :documents, :date, :datetime
  end
end
