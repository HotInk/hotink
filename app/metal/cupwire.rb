# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Cupwire < ArticleStream::App
  set :owner_account_id, 24
  
  get '/cupwire/members' do
    load_session
    
    unless current_user.has_role?('manager', @account) || current_user.has_role?('admin')
      halt 401, "Unauthorized"
    end
    @accounts = Account.all
    erb :members
  end
  
  post '/cupwire/members' do
    load_session
    unless current_user.has_role?('manager', @account) || current_user.has_role?('admin')
      halt 401, "Unauthorized"
    end

    @accounts = Account.all
    
    if params[:account]
      @accounts.each do |account|
        member_status = params[:account][account.id.to_s][:cup_member]
        if member_status=='yes'
          account.create_membership unless account.membership
        elsif member_status=='no'
          account.membership.destroy if account.membership
          account.reload
        end
      end
    end
    
    redirect '/stream'
  end
  
  # Public user checkout url
  post '/cupwire/checkout_article/:id' do
    @current_user = current_user
    
    @account = current_user.account
    Time.zone = @account.time_zone
    
    @article = Article.find(params[:id])
    
    unless @current_user && @account
      redirect "/sso/login?return_to=#{params[:return_to]}"
    end
    
    @checkout = Checkout.new
    @checkout.original_article = @article
          
    Checkout.transaction do
      @checkout.duplicate_article = @article.photocopy(@account)        
      @checkout.user = @current_user
      @checkout.save!
    end
    
    redirect params[:return_to] || "http://cup.ca"
  end
  
end
