class CreateSignOffs < ActiveRecord::Migration
  def self.up
    create_table :sign_offs do |t|
      t.integer :article_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sign_offs
  end
end
