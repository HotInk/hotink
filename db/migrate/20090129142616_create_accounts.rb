class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.string :formal_name
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
