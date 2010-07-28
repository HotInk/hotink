class AddDeltaToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :delta, :boolean
  end

  def self.down
    remove_column :comments, :delta
  end
end
