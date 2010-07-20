class AddLeadArticleIdsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :lead_article_ids, :string
  end

  def self.down
    remove_column :accounts, :lead_article_ids
  end
end
