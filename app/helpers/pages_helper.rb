module PagesHelper
  
  def page_form_options_collection(account)
    pages = account.pages.main_pages.all.inject([]) do |pages_array, page|
      pages_array << page
      children = child_pages_array(page)
      pages_array << children unless children.blank? 
      pages_array
    end
    pages.flatten
  end
  
  private
  
  def child_pages_array(page)
    page.child_pages.inject([]) do |child_array, page|
      child_array << page
      child_array << child_pages_array(page) unless page.child_pages.blank?
      child_array
    end
  end
end
