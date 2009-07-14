class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors, :options => 'DEFAULT CHARSET=utf8 COLLATE=utf8_bin' do |t|
      t.string :name, :options => 'COLLATE utf_bin'
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :authors
  end
end
