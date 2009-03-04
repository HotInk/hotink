class AddCaptionToWaxing < ActiveRecord::Migration
  def self.up
    add_column :waxings, :caption, :string
  end

  def self.down
    remove_column :waxings, :caption
  end
end
