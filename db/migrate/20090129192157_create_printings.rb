class CreatePrintings < ActiveRecord::Migration
  def self.up
    create_table :printings do |t|
      t.integer :article_id
      t.integer :issue_id
      t.string :page_number
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :printings
  end
end
