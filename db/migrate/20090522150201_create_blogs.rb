class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :title
      t.text :description
      t.integer :account_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
