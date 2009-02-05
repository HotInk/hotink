class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id
      t.integer :account_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
