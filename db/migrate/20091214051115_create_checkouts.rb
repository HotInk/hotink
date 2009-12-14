class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.integer :original_article_id
      t.integer :duplicate_article_id

      t.timestamps
    end
    add_index :checkouts, :original_article_id
    add_index :checkouts, :duplicate_article_id
  end

  def self.down
    drop_table :checkouts
  end
end
