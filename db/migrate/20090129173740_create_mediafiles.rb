class CreateMediafiles < ActiveRecord::Migration
  def self.up
    create_table :mediafiles do |t|
      t.string :title
      t.text :description
      t.string :link_alternate
      t.date :date
      t.integer :account_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :mediafiles
  end
end
