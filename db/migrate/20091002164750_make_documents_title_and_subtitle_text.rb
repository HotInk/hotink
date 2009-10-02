class MakeDocumentsTitleAndSubtitleText < ActiveRecord::Migration
  def self.up
    change_column :documents, :title, :text
    change_column :documents, :subtitle, :text
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
