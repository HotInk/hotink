# The queries controller is an api-only controller used to provide
# api users with very specific data without any waste.
class QueriesController < ApplicationController
  def show
    @results = []
    num_records = params[:count] || 5

    case params[:group_by]
    when "section"
      for section in @account.main_categories
         @results += @account.articles.find(:all, :conditions => { :section_id => section.id, :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end  
    when "blog"
      for blog in @account.blogs
         @results += blog.entries.find(:all, :conditions => { :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end
    end

     respond_to do |format|
       format.xml { render :xml => @results }
     end
   end
end
