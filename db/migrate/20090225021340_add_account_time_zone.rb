class AddAccountTimeZone < ActiveRecord::Migration
  def self.up
    add_column :accounts, :time_zone, :string
  end

  def self.down
    remove_column :accounts, :time_zone
  end
end
