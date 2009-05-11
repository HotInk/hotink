class AddPdfFieldsToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :pdf_file_name, :string
    add_column :issues, :pdf_file_size, :integer
    add_column :issues, :pdf_updated_at, :datetime
  end

  def self.down
    remove_column :issues, :pdf_file_name
    remove_column :issues, :pdf_file_size
    remove_column :issues, :pdf_updated_at
  end
end
