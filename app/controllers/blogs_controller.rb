class BlogsController < ApplicationController
  
  layout 'hotink'
  
  def new
    @blog = @account.blogs.build
  end
  
  
end
