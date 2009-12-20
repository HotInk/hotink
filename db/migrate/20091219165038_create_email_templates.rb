class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :email_templates do |t|
      t.text :html
      t.text :plaintext
      t.string :name
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_templates
  end
end
