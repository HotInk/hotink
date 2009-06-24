class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :title
      t.string :alternate_title
      t.string :subtitle
      t.text :bodytext
      t.string :summary
      t.datetime :date
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
