ActionController::Routing::Routes.draw do |map|
  
  map.root :controller => "accounts", :action =>"index"
  
  map.resources :account_invitations, :only => [:create, :edit, :update, :destroy]
  
  map.resources :password_resets
  map.resources :users, :member => { :promote => :put, :demote => :put, :deputize => :put, :letgo => :delete }
  
  map.current_design '/accounts/:account_id/current_design', :controller => :designs, :action => :current_design

  map.resources :accounts do |account|
    account.resources :invitations, :only => [:new, :create, :edit, :update, :destroy]
    account.resources :user_invitations, :only => [:create, :edit, :update, :destroy]
    
    account.resource :front_page, :only => [:edit, :update]
    
    account.resources :designs do |design|
      design.resources :templates
      design.resources :template_files
    end
    
    account.resources :documents do |document|
      document.resources :mediafiles
      document.resources :waxings
    end
    
    account.resources :articles, :collection => { :search => :get } do |article|
      article.resources :mediafiles
      article.resources :authors
      article.resources :tags
      article.resources :waxings
      article.resources :printings
    end
    
    account.resources :mediafiles do |mediafile|
      mediafile.resources :authors
      mediafile.resources :tags
    end
    
    account.resources :blogs, :member => { :manage_contributors => :get, :add_contributor => :put, :remove_contributor => :put, :promote_contributor => :put, :demote_contributor => :put } do |blog|
      blog.resources :entries do |entry|
        entry.resources :mediafiles
        entry.resources :waxings
        entry.resources :tags
      end
    end
    
    account.resources :entries, :only => [:new, :edit, :update, :destroy] do |entry|
      entry.resources :mediafiles
      entry.resources :waxings
      entry.resources :tags
    end
    
    account.resources :lists, :except => :show
    account.resources :pages
    account.resources :issues, :member => { :upload_pdf => :post } 
    account.resources :authors
    account.resources :categories, :member => { :deactivate => :put, :reactivate => :put }
    account.resources :waxings
    account.resources :actions
    
    account.resource :search
    account.resource :dashboard
    
    account.resources :public_articles
    account.resources :public_blogs
    account.resources :public_issues
    account.public_blog_entry '/public_blogs/:blog_slug/:id', :controller => :public_entries, :action => :show
    account.public_search '/search', :controller => :public_search, :action => :show
    account.public_front_page '/front_page', :controller => :public_front_pages, :action => :show
    account.public_category '/public_categories/*id', :controller => :public_categories, :action => :show
    account.front_page_preview '/front_page/preview', :controller => :public_front_pages, :action => :preview 
    account.public_page '/public_pages/*id', :controller => :public_pages, :action => :show      
  end
  
  # You can search or query anything, regardless of account.
  map.resource :search
  
end
