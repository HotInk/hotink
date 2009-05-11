class AddFileUpdatedAtToMediafiles < ActiveRecord::Migration
  def self.up
    add_column :mediafiles, :file_updated_at, :datetime
  end

  def self.down
    remove_column :mediafiles, :file_updated_at
  end
end
