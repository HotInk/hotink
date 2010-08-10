class List < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  
  has_many :list_items, :order => :position, :dependent => :destroy
  has_many :documents, :through => :list_items, :order => "list_items.position"
  
  validates_presence_of :name
  validates_format_of :name, :with => /^[a-zA-Z][-a-zA-Z ]+$/i, :message => 'can only contain letters, spaces and hyphens'
  validates_uniqueness_of :name, :scope => :account_id
  
  validates_presence_of :slug
  def validate
    errors.add("name", "is reserved, choose another") if ContentDrop.instance_methods.include?(slug)
  end
  before_validation :generate_slug
  
  
  belongs_to :owner, :class_name => "User"
  
  def documents=(new_documents)
    new_documents.each_index do |i|
      if current_li = list_items.find_by_position(i)
        current_li.document = new_documents[i]
        current_li.save
      else
        list_items.create(:document => new_documents[i], :position => i)
      end
      list_items[new_documents.length..-1].each { |li| li.destroy } if list_items[new_documents.length..-1]
    end
    touch
  end
  
  private
  
  def generate_slug
    self.slug = self.name.downcase.gsub(/[- ]/, "_") if self.name&&self.name_changed?
  end
  
end