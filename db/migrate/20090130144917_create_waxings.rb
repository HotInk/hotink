class CreateWaxings < ActiveRecord::Migration
  def self.up
    create_table :waxings do |t|
      t.integer :mediafile_id
      t.integer :article_id
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :waxings
  end
end
