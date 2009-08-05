class AddIncludeToClientApplications < ActiveRecord::Migration
  def self.up
    add_column :client_applications, :include, :string
  end

  def self.down
    remove_column :client_applications, :include
  end
end
