class CreatePhotocredits < ActiveRecord::Migration
  def self.up
    create_table :photocredits do |t|
      t.integer :attachment_id
      t.integer :author_id
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :photocredits
  end
end
