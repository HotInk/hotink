class UserActivationsController < ApplicationController
  
  skip_before_filter :find_account
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  
  def new  
    render  
  end  

  def create
    # params[account_id] comes from the form here, not the url as usual, 
    # so we skip the filter and make it explicit  
    @account = find_account 
    @user = @account.users.build(params[:user_activation])  
    if @user.save_as_inactive  
      @user.deliver_user_activation_instructions!  
      flash[:notice] = "New user added, activation instructions emailed"
      respond_to do |format|
        format.js
      end
    else  
      flash[:notice] = "No user was found with that email address"  
      redirect_to account_articles_url(@user.account)
    end  
  end 
   
   def edit  
     @account = @user.account # find_account filter is skipped for this controller 
     render :layout => 'login' 
   end  
   
   # This action simply catches invalid users and tosses them back to the form.
   def update            
     begin
       @user.update_attributes!(params[:user])
     rescue ActiveRecord::RecordInvalid => invalid
        render :action=>"edit", :layout=>'login'
     else
       @user.account.accepts_role "staff", @user
       flash[:notice] = "Welcome to Hot Ink!"
       redirect_to account_articles_url(@user.account)
     end
   end
   
   private  
   
   def load_user_using_perishable_token  
     # Make user activation url valid for 1 full day.
     @user = User.find_using_perishable_token(params[:id], 1.day)  
     unless @user  
       flash[:notice] = "We're sorry, but we could not locate your account. " +  
       "If you are having issues try copying and pasting the URL " +  
       "from your email into your browser or restarting the " +  
       "process."  
       redirect_to root_url  
     end
   end
   
end
