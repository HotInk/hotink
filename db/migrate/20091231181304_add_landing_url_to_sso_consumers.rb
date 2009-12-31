class AddLandingUrlToSsoConsumers < ActiveRecord::Migration
  def self.up
    add_column :sso_consumers, :landing_url, :string
  end

  def self.down
    remove_column :sso_consumers, :landing_url
  end
end
