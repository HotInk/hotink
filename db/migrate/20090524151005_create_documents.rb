class CreateDocuments < ActiveRecord::Migration
  def self.up
    rename_table :articles, :documents
    add_column :documents, :type, :string
    
    rename_column :authorships, :article_id, :document_id
    rename_column :printings, :article_id, :document_id
    rename_column :sortings, :article_id, :document_id
    rename_column :waxings, :article_id, :document_id
  
  end

  def self.down
    remove_column :documents, :type
    rename_table :documents, :articles
    
    rename_column :authorships, :document_id, :article_id
    rename_column :printings, :document_id, :article_id
    rename_column :sortings, :document_id, :article_id
    rename_column :waxings, :document_id, :article_id
    
  end
end
