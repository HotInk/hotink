class AddDeltaToMediafiles < ActiveRecord::Migration
  def self.up
    add_column :mediafiles, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :mediafiles, :delta
  end
end
