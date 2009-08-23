class AddStatusToMediafiles < ActiveRecord::Migration
  def self.up
    add_column :mediafiles, :status, :string, :default => 'published', :null => false
  end

  def self.down
    remove_column :mediafiles, :status
  end
end
