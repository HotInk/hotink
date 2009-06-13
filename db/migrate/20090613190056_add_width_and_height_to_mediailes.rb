class AddWidthAndHeightToMediailes < ActiveRecord::Migration
  def self.up
    add_column :mediafiles, :width, :integer
    add_column :mediafiles, :height, :integer
  end

  def self.down
    remove_column :mediafiles, :width
    remove_column :mediafiles, :height
  end
end
