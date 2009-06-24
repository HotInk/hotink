class CreateAuthorships < ActiveRecord::Migration
  def self.up
    create_table :authorships, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :staff_position
      t.integer :article_id
      t.integer :author_id
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :authorships
  end
end
