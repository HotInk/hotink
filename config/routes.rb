ActionController::Routing::Routes.draw do |map|
  
  map.root :controller => "accounts", :action =>"new"
  
  map.resources :invitations, :only => [:new, :create, :edit, :update, :destroy]
  map.resources :password_resets
  map.resources :users, :member => { :promote => :put, :demote => :put, :deputize => :put, :letgo => :delete }
  
  map.resources :accounts do |account|
    account.resources :invitations, :only => [:new, :create, :edit, :update, :destroy]
    
    # No content exists in Hot Ink without belonging to an account, routing reflects this fact.
    account.resources :documents do |document|
      document.resources :mediafiles
      document.resources :waxings
    end
    account.resources :articles do |article|
      article.resources :mediafiles
      article.resources :authors
      article.resources :sortings
      article.resources :tags
      article.resources :waxings
      article.resources :printings
    end
    account.resources :mediafiles do |mediafile|
      mediafile.resources :authors
      mediafile.resources :tags
    end
    account.resources :blogs, :member => { :add_user => :put, :remove_user => :put, :promote_user => :put } do |blog|
      blog.resources :entries do |entry|
        entry.resources :mediafiles
        entry.resources :waxings
        entry.resources :tags
      end
    end
    account.resources :entries do |entry|
      entry.resources :mediafiles
      entry.resources :waxings
      entry.resources :tags
    end
    account.resources :issues, :member => { :upload_pdf => :post } do |issue|
    end
    account.resources :authors
    account.resources :sections do |section|
      section.resources :articles do |article|
        article.resources :mediafiles
        article.resources :authors
        article.resources :sortings
        article.resources :tags
        article.resources :waxings
      end
    end
    account.resources :categories, :member => { :deactivate => :put, :reactivate => :put }
    account.resources :images
    account.resources :audiofiles
    account.resources :waxings
    
    account.resources :apps
    account.resources :actions
    
    account.resource :search
  end
  
  # You can search or query anything, regardless of account.
  map.resource :search
  
end
