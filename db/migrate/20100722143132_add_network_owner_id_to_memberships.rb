class AddNetworkOwnerIdToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :network_owner_id, :integer
  end

  def self.down
    remove_column :memberships, :network_owner_id
  end
end
