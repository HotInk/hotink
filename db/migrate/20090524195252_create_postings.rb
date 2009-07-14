class CreatePostings < ActiveRecord::Migration
  def self.up
    create_table :postings, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.integer :account_id
      t.integer :entry_id
      t.integer :blog_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :postings
  end
end
