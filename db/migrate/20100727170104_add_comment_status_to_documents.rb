class AddCommentStatusToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :comment_status, :string, :default => 'enabled'
  end

  def self.down
    remove_column :documents, :comment_status
  end
end
