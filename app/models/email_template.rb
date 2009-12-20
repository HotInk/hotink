require 'liquid'

class EmailTemplate < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account
  validates_presence_of :name
  
  def render_html(template_variables)
    Liquid::Template.parse(html).render(template_variables)
  end
  
  def render_plaintext(template_variables)
    Liquid::Template.parse(plaintext).render(template_variables)
  end
end
