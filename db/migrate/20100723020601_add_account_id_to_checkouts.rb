class AddAccountIdToCheckouts < ActiveRecord::Migration
  def self.up
    add_column :checkouts, :account_id, :integer
  end

  def self.down
    remove_column :checkouts, :account_id
  end
end
