# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Cupwire < ArticleStream::App
  set :owner_account_id, 2
  
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
end
