class CreateSsoConsumers < ActiveRecord::Migration
  def self.up
    create_table :sso_consumers do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :sso_consumers
  end
end
