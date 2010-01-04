class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :email
      t.boolean :redeemed, :default => false
      t.integer :user_id
      t.integer :account_id
      t.string :type
      t.string :token

      t.timestamps
    end
    add_index :invitations, :token
  end

  def self.down
    drop_table :invitations
  end
end
