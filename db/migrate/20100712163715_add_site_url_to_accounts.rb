class AddSiteUrlToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :site_url, :string
  end

  def self.down
    remove_column :accounts, :site_url
  end
end
