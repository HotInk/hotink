ActionController::Routing::Routes.draw do |map|
  
  map.root :controller => "accounts", :action =>"index"
  
  map.resources :invitations, :only => [:new, :create, :edit, :update, :destroy]
  map.resources :password_resets
  map.resources :users, :member => { :promote => :put, :demote => :put, :deputize => :put, :letgo => :delete }
  
  # Old invitation route support
  map.connect '/user_activations/:id/edit', :controller => 'invitations'
  map.connect '/account_activations/:id/edit', :controller => 'invitations'
  map.current_design '/accounts/:account_id/current_design', :controller => :designs, :action => :current_design
  
  map.resources :accounts do |account|
    account.resources :invitations, :only => [:new, :create, :edit, :update, :destroy]
    
    account.resource :front_page, :only => [:edit, :update]
    
    account.resources :designs do |design|
      design.resources :templates
      design.resources :template_files
    end
    
    account.resources :documents do |document|
      document.resources :mediafiles
      document.resources :waxings
    end
    
    account.resources :articles do |article|
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
    
    account.resources :issues, :member => { :upload_pdf => :post } 
    account.resources :authors
    account.resources :categories, :member => { :deactivate => :put, :reactivate => :put }
    account.resources :waxings
    account.resources :apps
    account.resources :actions
    
    account.resource :search
    account.resource :dashboard
  end
  
  # You can search or query anything, regardless of account.
  map.resource :search
  
end
