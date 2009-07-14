class CreateSortings < ActiveRecord::Migration
  def self.up
    create_table :sortings, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.integer :category_id
      t.integer :article_id
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sortings
  end
end
