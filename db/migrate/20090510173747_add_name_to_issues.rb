class AddNameToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :name, :string
  end

  def self.down
    remove_column :issues, :name
  end
end
