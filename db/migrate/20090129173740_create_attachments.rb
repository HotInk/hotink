class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :filename
      t.string :file_type
      t.integer :filesize
      t.string :title
      t.text :description
      t.integer :width
      t.integer :height
      t.string :length
      t.string :link_alternate
      t.date :date
      t.integer :account_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
