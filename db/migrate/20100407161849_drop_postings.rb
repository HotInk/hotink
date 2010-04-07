class DropPostings < ActiveRecord::Migration
  def self.up
    drop_table :postings
  end

  def self.down
    create_table :postings, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.integer :account_id
      t.integer :entry_id
      t.integer :blog_id
      
      t.timestamps
    end
  end
end
