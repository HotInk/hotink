ActionController::Routing::Routes.draw do |map|
  
  map.root :controller => "accounts", :action =>"new"
  
  map.resource :user_session
  map.resource :remote_session
  map.resources :user_activations
  map.resources :password_resets
  map.resources :users, :member => { :promote => :put, :demote => :put, :deputize => :put, :letgo => :delete }
  
  map.resources :oauth_clients
  map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
  map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
  map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
  map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'

  # No content exists in Hot Ink without belonging to an account, routing reflects this fact.
  map.resources :account_activations
  map.resources :accounts do |account|
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
    account.resources :issues, :member => { :upload_pdf => :post } do |issue|
      issue.resources :articles do |article|
        article.resources :mediafiles
        article.resources :authors
        article.resources :sortings
        article.resources :tags
        article.resources :waxings
      end
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
    account.resources :categories
    account.resources :images
    account.resources :audiofiles
    account.resources :waxings
    
    account.resources :apps
    account.resources :actions
  end
  

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
