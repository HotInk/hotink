class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.date :date
      t.integer :number
      t.integer :volume
      t.string :description
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
